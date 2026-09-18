# امین فارکس | Amin Forex

> مرجع دانلود رایگان اندیکاتورهای MetaTrader 5 با فایل اصلی MQL5

[![GitHub Pages](https://img.shields.io/badge/Hosted%20on-GitHub%20Pages-blue)](https://aminlore030-dot.github.io/amin-forex/)
[![License](https://img.shields.io/badge/License-Free-green)](#)
[![MT5](https://img.shields.io/badge/MetaTrader-5-blue)](#)

**امین فارکس** یک وب‌سایت فارسی و حرفه‌ای برای انتشار و دانلود رایگان اندیکاتورهای MetaTrader 5 است. تمام اندیکاتورها با فرمت اصلی MQL5 و بدون هیچ تغییری در کد ارائه می‌شوند.

## ✨ ویژگی‌ها

- ✅ **۲۸+ اندیکاتور رایگان** با فایل اصلی MQL5
- ✅ **۱۰۰٪ فارسی و RTL** با فونت Vazirmatn
- ✅ **جستجو و فیلتر پیشرفته** بر اساس نام و دسته‌بندی
- ✅ **صفحه اختصاصی** برای هر اندیکاتور با توضیحات کامل
- ✅ **طراحی واکنش‌گرا** (Responsive) برای موبایل، تبلت و دسکتاپ
- ✅ **دارک مود حرفه‌ای** با تم تریدینگ
- ✅ **بدون Backend** - کاملاً Static و قابل میزبانی در GitHub Pages
- ✅ **سرعت بالا** - بدون وابستگی به فریمورک سنگین

## 📂 ساختار پروژه

```
amin-forex/
├── index.html              # صفحه اصلی
├── indicators.html         # لیست تمام اندیکاتورها
├── indicator.html          # صفحه جزئیات یک اندیکاتور (با ?id=...)
├── install.html            # آموزش نصب در MT5
├── about.html              # درباره ما
├── README.md
├── .gitignore
├── indicators/             # فایل‌های MQ5 (28 فایل)
│   ├── 18AvgMA.mq5
│   ├── MACD.mq5
│   └── ...
├── images/                 # تصاویر پیش‌نمایش هر اندیکاتور
│   ├── 18AvgMA.png
│   └── ...
├── data/
│   └── indicators.json     # داده‌های ساختاریافته
└── assets/
    ├── css/
    │   └── style.css
    └── js/
        └── main.js
```

## 🚀 نصب و راه‌اندازی

### اجرا به صورت محلی

پروژه کاملاً static است و نیازی به نصب هیچ ابزاری نیست:

```bash
# کافیست فایل index.html را در مرورگر باز کنید
# یا از یک سرور ساده استفاده کنید
python3 -m http.server 8000
```

سپس در مرورگر به `http://localhost:8000` بروید.

### استقرار در GitHub Pages

1. این Repository را Fork کنید.
2. در تنظیمات Repository به بخش **Pages** بروید.
3. Source را روی **main** و Folder را روی **/(root)** تنظیم کنید.
4. سایت شما در آدرس `https://USERNAME.github.io/amin-forex/` در دسترس خواهد بود.

## 📝 افزودن اندیکاتور جدید

برای افزودن یک اندیکاتور جدید:

1. فایل `.mq5` را در پوشه `indicators/` قرار دهید.
2. تصویر پیش‌نمایش را در پوشه `images/` قرار دهید.
3. اطلاعات اندیکاتور را به فایل `data/indicators.json` اضافه کنید:

```json
{
  "id": "my-indicator",
  "filename": "MyIndicator.mq5",
  "title": "نام فارسی اندیکاتور",
  "titleEn": "English Name",
  "category": "trend",
  "categoryLabel": "روند",
  "shortDescription": "توضیح کوتاه",
  "description": "توضیح کامل",
  "features": ["ویژگی ۱", "ویژگی ۲"],
  "inputs": [
    {"name": "Period", "label": "دوره", "default": "14"}
  ],
  "image": "MyIndicator.png",
  "downloadPath": "indicators/MyIndicator.mq5"
}
```

## 🎯 دسته‌بندی‌ها

- **روند** (Trend) - اندیکاتورهای تشخیص روند
- **نوسانگر** (Oscillator) - اسیلاتورها
- **نوسان** (Volatility) - اندیکاتورهای نوسان
- **بیل ویلیامز** (Bill Williams) - اندیکاتورهای بیل ویلیامز

## 🔗 لینک‌های مفید

- [مستندات MQL5](https://www.mql5.com/en/docs)
- [مخزن رسمی MQL5](https://github.com/mql5)
- [انجمن MQL5](https://www.mql5.com/en/forum)

## 📜 لایسنس

این پروژه برای استفاده آزاد در دسترس است. فایل‌های MQ5 ممکن است لایسنس‌های جداگانه‌ای داشته باشند که در توضیحات هر اندیکاتور ذکر شده‌اند.

---

**ساخته شده با ❤️ برای معامله‌گران ایرانی**