// SPDX-License-Identifier: GPL-2.0-or-later

/*												  */
/* The OCOTP driver for Sunplus									  */
/*												  */
/* Copyright (C) 2019 Sunplus Technology Inc., All rights reseerved.				  */
/*												  */
/* Author: Sunplus										  */
/*												  */
/* This program is free software; you can redistribute is and/or modify it			  */
/* under the terms of the GNU General Public License as published by the			  */
/* Free Software Foundation; either version 2 of the License, or (at your			  */
/* option) any later version.									  */
/*												  */
/* This program is distributed in the hope that it will be useful, but				  */
/* WITHOUT ANY WARRANTY; without even the implied warranty of					  */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU				  */
/* General Public License for more details							  */
/*												  */
/* You should have received a copy of the GNU General Public License along			  */
/* with this program; if not, write to the Free Software Foundation, Inc.,			  */
/* 675 Mass Ave, Cambridge, MA 02139, USA.							  */
/*												  */

#include <linux/clk.h>
#include <linux/delay.h>
#include <linux/device.h>
#include <linux/of_device.h>
#include <linux/io.h>
#include <linux/module.h>
#include <linux/nvmem-provider.h>
#include <linux/of.h>
#include <linux/platform_device.h>
#include <linux/slab.h>
#include <linux/version.h>

#include <linux/firmware/sp-ocotp.h>

enum base_type {
	HB_GPIO,
	OTPRX,
#if defined(CONFIG_SOC_SP7350)
	OTP_KEY,
#endif
	BASEMAX,
};

struct sp_otp_data_t {
	struct device *dev;
	void __iomem *base[BASEMAX];
	struct clk *clk;
	struct nvmem_config *config;
#if defined(CONFIG_SOC_Q645)
	int id;
#endif
};

static int sp_otp_wait(void __iomem *_base)
{
	struct sp_otprx_reg *otprx_reg_ptr = (struct sp_otprx_reg *)(_base);
	int timeout = OTP_READ_TIMEOUT;
	unsigned int status;

	do {
		udelay(10);
		if (timeout-- == 0)
			return -ETIMEDOUT;

		status = readl(&otprx_reg_ptr->otp_cmd_status);
	} while ((status & OTP_READ_DONE) != OTP_READ_DONE);

	return 0;
}

int sp_otp_read_real(struct sp_otp_data_t *_otp, int addr, char *value)
{
	struct sp_hb_gpio_reg *hb_gpio_reg_ptr;
	struct sp_otprx_reg *otprx_reg_ptr;
#if defined(CONFIG_SOC_SP7350)
	struct sp_otp_key_reg *otp_key_reg_ptr;
#endif
	unsigned int addr_data;
	unsigned int byte_shift;
	int ret = 0;

	hb_gpio_reg_ptr = (struct sp_hb_gpio_reg *)(_otp->base[HB_GPIO]);
	otprx_reg_ptr = (struct sp_otprx_reg *)(_otp->base[OTPRX]);
#if defined(CONFIG_SOC_SP7350)
	otp_key_reg_ptr = (struct sp_otp_key_reg *)(_otp->base[OTP_KEY]);
#endif

	addr_data = addr % (OTP_WORD_SIZE * OTP_WORDS_PER_BANK);
	addr_data = addr_data / OTP_WORD_SIZE;

	byte_shift = addr % (OTP_WORD_SIZE * OTP_WORDS_PER_BANK);
	byte_shift = byte_shift % OTP_WORD_SIZE;

	addr = addr / (OTP_WORD_SIZE * OTP_WORDS_PER_BANK);
	addr = addr * OTP_BIT_ADDR_OF_BANK;

	writel(0x0, &otprx_reg_ptr->otp_cmd_status);
	writel(addr, &otprx_reg_ptr->otp_addr);
	writel(0x1E04, &otprx_reg_ptr->otp_cmd);

	ret = sp_otp_wait(_otp->base[OTPRX]);
	if (ret < 0)
		return ret;

#if defined(CONFIG_SOC_SP7350)
	if (addr < (16 * 32)) {
		*value = (readl(&hb_gpio_reg_ptr->hb_gpio_rgst_bus32_9 +
				addr_data) >> (8 * byte_shift)) & 0xFF;
	} else {
		*value = (readl(&otp_key_reg_ptr->block0_addr +
				addr_data) >> (8 * byte_shift)) & 0xFF;
	}
#else
	*value = (readl(&hb_gpio_reg_ptr->hb_gpio_rgst_bus32_9 +
				addr_data) >> (8 * byte_shift)) & 0xFF;
#endif

	return ret;
}

static int sp_ocotp_read(void *_c, unsigned int _off, void *_v, size_t _l)
{
	struct sp_otp_data_t *otp = _c;
	unsigned int addr;
	char *buf = _v;
	char value[4];
	int ret;

#if defined(CONFIG_SOC_SP7021)
	dev_dbg(otp->dev, "OTP read %u bytes at %u", _l, _off);

	if ((_off >= QAC628_OTP_SIZE) || (_l == 0) || ((_off + _l) > QAC628_OTP_SIZE))
		return -EINVAL;
#elif defined(CONFIG_SOC_Q645)
	dev_dbg(otp->dev, "OTP read %lu bytes at %u", _l, _off);

	if (otp->id == 0) {
		if ((_off >= QAK645_EFUSE0_SIZE) || (_l == 0) || ((_off + _l) > QAK645_EFUSE0_SIZE))
			return -EINVAL;
	} else if (otp->id == 1) {
		if ((_off >= QAK645_EFUSE1_SIZE) || (_l == 0) || ((_off + _l) > QAK645_EFUSE1_SIZE))
			return -EINVAL;
	} else if (otp->id == 2) {
		if ((_off >= QAK645_EFUSE0_SIZE) || (_l == 0) || ((_off + _l) > QAK645_EFUSE2_SIZE))
			return -EINVAL;
	}
#elif defined(CONFIG_SOC_SP7350)
	dev_dbg(otp->dev, "OTP read %lu bytes at %u", _l, _off);

	if ((_off >= QAK654_OTP_SIZE) || (_l == 0) || ((_off + _l) > QAK654_OTP_SIZE))
		return -EINVAL;
#endif

	ret = clk_enable(otp->clk);
	if (ret)
		return ret;

	*buf = 0;
	for (addr = _off; addr < (_off + _l); addr++) {
		ret = sp_otp_read_real(otp, addr, value);
		if (ret < 0) {
			dev_err(otp->dev, "OTP read fail:%d at %d", ret, addr);
			goto disable_clk;
		}

		*buf++ = *value;
	}

disable_clk:
	clk_disable(otp->clk);
	dev_dbg(otp->dev, "OTP read complete");

	return ret;
}

#if defined(CONFIG_SOC_SP7021)
static struct nvmem_config sp_ocotp_nvmem_config = {
	.name = "sp-ocotp",
	.read_only = true,
	.word_size = 1,
	.size = QAC628_OTP_SIZE,
	.stride = 1,
	.reg_read = sp_ocotp_read,
	.owner = THIS_MODULE,
};
#elif defined(CONFIG_SOC_Q645)
static struct nvmem_config sp_ocotp_nvmem_config[3] = {
	{
		.name = "sp-ocotp0",
		.read_only = true,
		.word_size = 1,
		.size = QAK645_EFUSE0_SIZE,
		.stride = 1,
		.reg_read = sp_ocotp_read,
		.owner = THIS_MODULE,
	},

	{
		.name = "sp-ocotp1",
		.read_only = true,
		.word_size = 1,
		.size = QAK645_EFUSE1_SIZE,
		.stride = 1,
		.reg_read = sp_ocotp_read,
		.owner = THIS_MODULE,
	},

	{
		.name = "sp-ocotp2",
		.read_only = true,
		.word_size = 1,
		.size = QAK645_EFUSE2_SIZE,
		.stride = 1,
		.reg_read = sp_ocotp_read,
		.owner = THIS_MODULE,
	},
};
#elif defined(CONFIG_SOC_SP7350)
static struct nvmem_config sp_ocotp_nvmem_config = {
	.name = "sp-ocotp",
	.read_only = true,
	.word_size = 1,
	.size = QAK654_OTP_SIZE,
	.stride = 1,
	.reg_read = sp_ocotp_read,
	.owner = THIS_MODULE,
};
#endif


void sp_ocotp_read_serial_num(void* sp_otp_data){

	extern unsigned long system_rev;
	extern unsigned long system_serial_low;
	extern unsigned long system_serial_high;

	u16 rev = 0;
	u8  uuid[20] = {0};
	sp_ocotp_read(sp_otp_data, 29, &rev, sizeof(u8) * 2);
	sp_ocotp_read(sp_otp_data, 32, uuid, sizeof(uuid));

	system_rev=  ((rev & 0xFF) << 8)  | ((rev & 0xFF00) >> 8);
	memcpy(&system_serial_low, uuid+8,sizeof(u8) * 4);
	memcpy(&system_serial_high, uuid+12,sizeof(u8) * 4);

}

int sp_ocotp_probe(struct platform_device *pdev)
{
	const struct of_device_id *match;
	const struct sp_otp_vX_t *sp_otp_vX = NULL;
	struct device *dev = &(pdev->dev);
	struct nvmem_device *nvmem;
	struct sp_otp_data_t *otp;
	struct resource *res;
	int ret;

	match = of_match_device(dev->driver->of_match_table, dev);
	if (match && match->data) {
		sp_otp_vX = match->data;
		// may be used to choose the parameters
	} else {
		dev_err(dev, "OTP vX does not match");
	}

	otp = devm_kzalloc(dev, sizeof(*otp), GFP_KERNEL);
	if (!otp)
		return -ENOMEM;

	otp->dev = dev;
#if defined(CONFIG_SOC_SP7021) || defined(CONFIG_SOC_SP7350)
	otp->config = &sp_ocotp_nvmem_config;
#elif defined(CONFIG_SOC_Q645)
	otp->id = pdev->id - 1;
	otp->config = &sp_ocotp_nvmem_config[otp->id];
#endif

	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "hb_gpio");
	otp->base[HB_GPIO] = devm_ioremap_resource(dev, res);
	if (IS_ERR(otp->base[HB_GPIO]))
		return PTR_ERR(otp->base[HB_GPIO]);

	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "otprx");
	otp->base[OTPRX] = devm_ioremap_resource(dev, res);
	if (IS_ERR(otp->base[OTPRX]))
		return PTR_ERR(otp->base[OTPRX]);

#if defined(CONFIG_SOC_SP7350)
	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "otp_key");
	otp->base[OTP_KEY] = devm_ioremap_resource(dev, res);
	if (IS_ERR(otp->base[OTP_KEY]))
		return PTR_ERR(otp->base[OTP_KEY]);
#endif

	otp->clk = devm_clk_get(&pdev->dev, NULL);
	if (IS_ERR(otp->clk))
		return PTR_ERR(otp->clk);

	ret = clk_prepare(otp->clk);
	if (ret < 0) {
		dev_err(dev, "failed to prepare clk: %d\n", ret);
		return ret;
	}
	clk_enable(otp->clk);

#if defined(CONFIG_SOC_SP7021) || defined(CONFIG_SOC_SP7350)
	sp_ocotp_nvmem_config.priv = otp;
	sp_ocotp_nvmem_config.dev = dev;
#elif defined(CONFIG_SOC_Q645)
	sp_ocotp_nvmem_config[otp->id].priv = otp;
	sp_ocotp_nvmem_config[otp->id].dev = dev;
#endif

	// devm_* >= 4.15 kernel
	// nvmem = devm_nvmem_register(dev, &sp_ocotp_nvmem_config);

#if defined(CONFIG_SOC_SP7021) || defined(CONFIG_SOC_SP7350)
	nvmem = nvmem_register(&sp_ocotp_nvmem_config);
#elif defined(CONFIG_SOC_Q645)
	nvmem = nvmem_register(&sp_ocotp_nvmem_config[otp->id]);
#endif
	if (IS_ERR(nvmem)) {
		dev_err(dev, "error registering nvmem config\n");
		return PTR_ERR(nvmem);
	}

	platform_set_drvdata(pdev, nvmem);

#if defined(CONFIG_SOC_SP7021)
	dev_dbg(dev, "clk:%ld banks:%d x wpb:%d x wsize:%d = %d",
		clk_get_rate(otp->clk),
		QAC628_OTP_NUM_BANKS, OTP_WORDS_PER_BANK,
		OTP_WORD_SIZE, QAC628_OTP_SIZE);
	sp_ocotp_read_serial_num(otp);

#elif defined(CONFIG_SOC_Q645)
	if (otp->id == 0) {
		dev_dbg(dev, "clk:%ld banks:%d x wpd:%d x wsize:%ld = %ld",
			clk_get_rate(otp->clk),
			QAK645_EFUSE0_NUM_BANKS, OTP_WORDS_PER_BANK,
			OTP_WORD_SIZE, QAK645_EFUSE0_SIZE);
	} else if (otp->id == 1) {
		dev_dbg(dev, "clk:%ld banks:%d x wpd:%d x wsize:%ld = %ld",
			clk_get_rate(otp->clk),
			QAK645_EFUSE1_NUM_BANKS, OTP_WORDS_PER_BANK,
			OTP_WORD_SIZE, QAK645_EFUSE1_SIZE);
	} else if (otp->id == 2) {
		dev_dbg(dev, "clk:%ld banks:%d x wpd:%d x wsize:%ld = %ld",
			clk_get_rate(otp->clk),
			QAK645_EFUSE2_NUM_BANKS, OTP_WORDS_PER_BANK,
			OTP_WORD_SIZE, QAK645_EFUSE2_SIZE);
	}
#elif defined(CONFIG_SOC_SP7350)
	dev_dbg(dev, "clk:%ld banks:%d x wpb:%d x wsize:%ld = %ld",
		clk_get_rate(otp->clk),
		QAK654_OTP_NUM_BANKS, OTP_WORDS_PER_BANK,
		OTP_WORD_SIZE, QAK654_OTP_SIZE);
#endif
	dev_info(dev, "by Sunplus (C) 2020");

	return 0;
}
EXPORT_SYMBOL_GPL(sp_ocotp_probe);

int sp_ocotp_remove(struct platform_device *pdev)
{
	// disbale for devm_*
	struct nvmem_device *nvmem = platform_get_drvdata(pdev);

	nvmem_unregister(nvmem);
	return 0;
}
EXPORT_SYMBOL_GPL(sp_ocotp_remove);

