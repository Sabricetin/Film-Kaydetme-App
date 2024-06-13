# Film Kaydetme Uygulaması

Bu Swift kodu, bir `UITableView` kullanarak filmleri listeleyen, kullanıcıların bu filmleri seçerek detaylarını görüntüleyebileceği ve yeni filmler ekleyebileceği bir iOS uygulaması oluşturuyor. Uygulama Core Data'yı kullanarak verileri saklar ve yönetir. Kod, temel olarak bir `UIViewController` sınıfını genişletir ve `UITableViewDelegate`, `UITableViewDataSource` ve diğer ilgili protokolleri uygular.

## Özellikler

- **Veri Kaynakları:**
  - `namArray`: Film isimlerini tutar.
  - `idArray`: Film ID'lerini (UUID) tutar.
  - `selectedFilm`: Seçilen filmin adı.
  - `selectedFilmId`: Seçilen filmin ID'si (UUID).

## View Did Load

- `tableView` için `delegate` ve `dataSource` atanır.
- Navigation bar'a "+" işareti eklenir ve `addButtonClicked` fonksiyonuna bağlanır.
- `getData` fonksiyonu çağrılarak veriler çekilir.

## View Will Appear

- `NotificationCenter` kullanılarak yeni veri eklenmesi durumunda `getData` fonksiyonunun çağrılması sağlanır.

## Verileri Çekme

- `getData`: Core Data'dan verileri çeker ve `namArray` ile `idArray` dizilerini doldurur. Yeni veriler geldiğinde `tableView` güncellenir.

## UITableViewDataSource

- `tableView(_:numberOfRowsInSection:)`: Satır sayısını `namArray` dizisinin eleman sayısı olarak döner.
- `tableView(_:cellForRowAt:)`: Her bir hücreyi film adıyla doldurur.

## UITableViewDelegate

- `tableView(_:didSelectRowAt:)`: Bir satır seçildiğinde, seçilen film atanır ve detaylar sayfasına geçiş yapılır (`performSegue`). `prepare(for:sender:)` yöntemiyle geçiş işlemi sırasında seçilen filmin adı ve ID'si, hedef `DetailsVC`'ye aktarılır.
- `tableView(_:commit:forRowAt:)`: Bir satır silindiğinde, ilgili film Core Data'dan silinir ve `tableView` güncellenir.

## Detay Sayfası (DetailsVC)

### Özellikler

- `chosenFilm`: Seçilen filmin adı.
- `chosenFilmId`: Seçilen filmin ID'si (UUID).

### View Did Load

- `chosenFilm` boş değilse, `saveButton` devre dışı bırakılır ve Core Data'dan veriler çekilerek ilgili alanlara doldurulur.
- `chosenFilm` boşsa, yeni bir film eklemek için gerekli ayarlar yapılır.
- Görsel seçmek ve klavyeyi kapatmak için ilgili `UITapGestureRecognizer` eklenir.

### Fotoğraf Seçme

- `selectImage`: Kullanıcıya fotoğraf seçme imkanı sunar.
- `picker(_:didFinishPicking:)`: Seçilen fotoğraf `imageView`'a atanır ve `saveButton` etkinleştirilir.

### Veriyi Kaydetme

- `kaydet(_:)`: Kullanıcı verileri girip kaydet butonuna bastığında, yeni film verileri Core Data'ya kaydedilir ve `NotificationCenter` ile ana sayfaya bildirim gönderilir.

### Ekran Görüntüleri

![Simulator Screen Recording - İphone 12 - 2024-06-13 at 23 45 46](https://github.com/Sabricetin/Film-Kaydetme-App/assets/114506296/ec384464-fa47-40c3-ac77-95c0ecbc6b85)

## Kullanım

- Ana ekranda film listesini göreceksiniz.
- Bir filme tıklayarak detaylarını görüntüleyebilir veya yeni bir film ekleyebilirsiniz.

