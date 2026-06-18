# RentACar Backend API

Bu proje ASP.NET Core Web API, Entity Framework Core, Katmanlı Yapı, DTO kullanarak backend geliştirme mantığını daha iyi kavramak, daha temiz bir mimaride çalışmayı öğrenmek ve pratik yapmak için geliştirdiğim temel seviyede bir backend API uygulamasıdır. Projede temel olarak müşteri, araç ve kiralama işlemleri yapılabilmektedir. Araçlar listelenebilir, yeni araç eklenebilir, güncellenebilir ve silinebilir. Müşteri ekleme ve listeleme işlemleri de bulunmaktadır. Kiralama tarafında ise araç müsaitlik kontrolü ve kiralama oluşturma işlemleri yapılabilmektedir.

## Kullandığım Teknolojiler ve Araçlar 

- ASP.NET Core Web API
- EF Core
- PostgreSQL
- Swagger
- DTO
- Repository Pattern
- Service Layer
- DI
- Migration

## Projede Yapılanlar

- Customer, Vehicle, VehicleType, Branch ve Rental entity yapıları oluşturuldu.
- EF Core ile veritabanı bağlantısı kuruldu.
- Code First yaklaşımıyla migration yapısı hazırlandı.
- Controller, Service ve Repository katmanları ayrıldı.
- DTO yapıları kullanılarak request modelleri düzenlendi.
- Araç kiralama için tarih aralığına göre müsaitlik kontrolü eklendi.
- Kiralama tutarı, aracın günlük ücretine göre hesaplanacak şekilde düzenlendi.
- Swagger üzerinden API endpointleri test edilebilir hale getirildi.

## Endpointler

Vehicles
GET /api/vehicles
GET /api/vehicles/{id}
POST /api/vehicles
PUT /api/vehicles/{id}
DELETE /api/vehicles/{id}

Customers
GET /api/customers
POST /api/customers

Rentals
GET /api/rentals
POST /api/rentals
GET /api/rentals/availability

Projeyi Çalıştırma

Öncelikle appsettings.json dosyasındaki PostgreSQL bağlantı ayarlarını düzenledim.

Projeyi çalıştırmak için:

dotnet restore
dotnet ef database update
dotnet run

Proje çalıştıktan sonra Swagger arayüzü üzerinden endpointleri test edebilirim.

https://localhost:{port}/swagger
