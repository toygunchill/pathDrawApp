# Konum Takip iOS Uygulaması

Konum Takip, kullanıcının hareketlerini gerçek zamanlı olarak takip eden ve rotaları görüntüleyen bir iOS uygulamasıdır. Uygulama, kullanıcının konumunu belirli aralıklarla kaydeder, rota üzerindeki önemli noktalarda işaretleyiciler (marker) oluşturur ve tamamlanan rotanın istatistiklerini gösterir.

## Özellikler

- **Gerçek Zamanlı Konum Takibi**: Kullanıcının gerçek zamanlı konumunu harita üzerinde gösterir
- **Otomatik Konum İşaretleme**: Her 100 metrelik hareket sonrası haritaya yeni bir işaretleyici ekler
- **Adres Bilgisi Gösterimi**: İşaretleyicilere tıklandığında tam adres bilgisini gösterir
- **Konum Takip Kontrolü**: Konum takibini açıp kapatma özelliği
- **Rota Görüntüleme**: Tüm işaretleyicileri birleştiren bir rota çizgisi görüntüleme
- **Rota İstatistikleri**: Rota görüntülendiğinde toplam mesafe, geçen süre ve ortalama hız bilgilerini gösterir
- **Rota Sıfırlama**: Mevcut rotayı temizleme özelliği
- **Rota Saklama**: Rotalar kalıcı olarak saklanır, uygulama yeniden açıldığında mevcut rota görüntülenir

## Mimari Yapı (MVVM)

Uygulama MVVM (Model-View-ViewModel) mimarisi kullanılarak geliştirilmiştir:

### Model
- `SavedLocation`: Konum bilgilerini saklar
- `RouteStatistics`: Rota istatistiklerini hesaplar ve tutar

### View
- `MapViewController`: Ana harita ekranını ve kullanıcı arayüzünü yönetir
- `RouteStatsSheetViewController`: Rota istatistiklerini gösteren alt sayfayı yönetir

### ViewModel
- `MapViewModel`: Konum takibi, rota yönetimi ve veri saklama işlemlerini gerçekleştirir
- Protocol delegeler aracılığıyla View ile iletişim kurar

### Yardımcı Bileşenler
- `LocationManager`: Konum işlemlerini yönetir
- `Constants`: Sabit değerleri merkezi bir yerde tutar

## Teknik Detaylar

### Kullanılan Teknolojiler
- Swift 5
- UIKit
- MapKit
- CoreLocation
- UserDefaults (veri saklama)

### Teknik Özellikler
- **Programatik UI**: Storyboard kullanmadan tamamen programatik arayüz
- **Protocol-Oriented Design**: Bileşenler arası iletişim protocol delegeler aracılığıyla
- **Asenkron Programlama**: Konum ve adres bilgisi işlemleri asenkron olarak gerçekleştirilir
- **SOLID Prensipleri**: Tek Sorumluluk, Açık/Kapalı ve Bağımlılığın Tersine Çevrilmesi prensiplerini uygular

## Kullanım

### Konum Takibi
1. Uygulamayı açın ve konum izni verin
2. Sağ üstteki "Konum Takibi" anahtarı ile takibi açıp kapatabilirsiniz
3. Hareket ettikçe her 100 metrede bir yeni işaretleyici eklenir

### Rota İşlemleri
- **Konuma Odaklan**: Sağ alttaki konum butonuna tıklayarak mevcut konumunuza odaklanabilirsiniz
- **Rotayı Görüntüle**: Ortadaki harita butonuna tıklayarak rotanızı görüntüleyebilir ve istatistikleri görebilirsiniz
- **Rotayı Sıfırla**: Sol alttaki çöp kutusu butonuna tıklayarak rotanızı temizleyebilirsiniz

## Kurulum

1. Projeyi klonlayın veya indirin
2. Xcode ile `caseloc.xcodeproj` dosyasını açın
3. Gerçek bir cihazda veya simülatörde çalıştırın.
4. Simülatörde tam deneyim için Features -> Locations -> City Bicycle Ride'ı aktif hale getirin.
