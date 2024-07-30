<p align="center">
  <a href="./README.md">English</a> |
  <a href="./README-FA.md">فارسی</a>
</p>
<h1 align="center">Tunnel Monitor</h1>

این مخزن شامل یک اسکریپت شل برای نظارت بر تونل‌های IPv6 در سرورهای لینوکسی است. اسکریپت به طور خودکار سروره

## ویژگی‌ها

- نظارت بر تونل‌های شبکه با نام‌های شامل `tun` یا `tunnel`.
- پینگ کردن سرورهای متصل از طریق آدرس‌های IPv6 آن‌ها.
- ثبت فعالیت‌ها و خطاها در فایل لاگ مشخص شده.
- ارائه منوی تعاملی برای نصب، به‌روزرسانی cron job و حذف اسکریپت.

## نصب

برای نصب و راه‌اندازی اسکریپت بر روی یک سرور اوبونتو، مراحل زیر را دنبال کنید:

### استفاده از cURL

برای دانلود و اجرای اسکریپت نصب با استفاده از `cURL`، دستور زیر را اجرا کنید:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Issei-177013/Tunnel-Monitor/main/install.sh)"
```

### استفاده از wget

برای دانلود و اجرای اسکریپت نصب با استفاده از `wget`، دستور زیر را اجرا کنید:

```bash
sudo bash -c "$(wget -O- https://raw.githubusercontent.com/Issei-177013/Tunnel-Monitor/main/install.sh)"
```