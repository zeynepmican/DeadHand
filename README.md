Dead Hand System Simulation (Verilog)
Bu proje, tehdit seviyesi, iletişim durumu ve sistem hatalarına bağlı olarak çalışan bir kontrol mekanizmasını modelleyen senkron bir finite state machine (FSM) tasarımını içermektedir. Sistem, farklı senaryolara göre durumlar arasında geçiş yaparak kritik durumlarda otomatik karar üretmektedir.

Özellikler
Senkron FSM tabanlı tasarım
Zamanlayıcı (timer) destekli durum geçişleri
Tehdit seviyesi, iletişim kesintisi ve hata durumlarına duyarlı yapı
Kritik senaryolarda otomatik aksiyon üretimi
Donanım seviyesinde karar mekanizması simülasyonu

Sistem Durumları
Sistem aşağıdaki temel durumlar arasında geçiş yapmaktadır:
Peace → Normal operasyon durumu
Alert → Artan tehdit seviyesi
Mobilization → Hazırlık ve aktif önlem süreci
Global War → Kritik ve geri dönüşsüz durum
Durum geçişleri; giriş sinyalleri ve zamanlayıcıya bağlı olarak kontrol edilmektedir.

Kullanılan Teknolojiler
Verilog HDL
(Varsa ekleyebilirsin) ModelSim / Vivado

Tasarım Detayları
Senkron tasarım yaklaşımı benimsenmiştir
FSM yapısı ile durum kontrolü sağlanmıştır
State encoding kullanılarak durumlar temsil edilmiştir
Zamanlama mekanizmaları ile kontrollü geçişler uygulanmıştır
