# RentACarApi

RentACarApi is a simple ASP.NET Core Web API project for a rent a car system. The goal is to demonstrate basic backend development concepts with a clean MVP structure.

## Technologies

- ASP.NET Core Web API
- Entity Framework Core
- PostgreSQL
- Swagger
- DTOs
- Service Layer
- Repository Pattern
- Dependency Injection
- Code First Migration

## Features

- Create and list customers
- Create, update, delete and list vehicles
- Create and list rentals
- Check vehicle availability by date range
- Calculate rental total amount from vehicle type daily price
- Seed vehicle types and branches

## Database Tables

- Customers
- VehicleTypes
- Vehicles
- Branches
- Rentals

## Business Rule

The same vehicle cannot be rented if the selected date range overlaps with an existing rental.

Overlap rule:

```text
rentDate < existingRental.ReturnDate && returnDate > existingRental.RentDate
```

## API Endpoints

### Vehicles

- `GET /api/vehicles`
- `GET /api/vehicles/{id}`
- `POST /api/vehicles`
- `PUT /api/vehicles/{id}`
- `DELETE /api/vehicles/{id}`

### Customers

- `GET /api/customers`
- `POST /api/customers`

### Rentals

- `GET /api/rentals`
- `POST /api/rentals`
- `GET /api/rentals/availability?vehicleId=1&rentDate=2026-06-21&returnDate=2026-06-24`

## How To Run

1. Update the PostgreSQL connection string in `appsettings.json` if needed.
2. Create the database with EF Core migration commands.
3. Run the API.
4. Open Swagger in the browser.

```bash
dotnet restore
dotnet ef migrations add InitialCreate
dotnet ef database update
dotnet run
```

Swagger URL:

```text
https://localhost:{port}/swagger
```

## Migration Commands

Install the EF Core CLI tool if it is not installed:

```bash
dotnet tool install --global dotnet-ef
```

Create migration and update database:

```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

## Sample Request Bodies

### POST /api/vehicles

```json
{
  "brand": "Toyota",
  "model": "Corolla",
  "modelYear": 2022,
  "plateNumber": "34ABC123",
  "vehicleTypeId": 2
}
```

### POST /api/customers

```json
{
  "firstName": "Utku",
  "lastName": "Ozturk",
  "email": "utku@example.com",
  "phoneNumber": "05555555555"
}
```

### POST /api/rentals

```json
{
  "customerId": 1,
  "vehicleId": 1,
  "branchId": 1,
  "rentDate": "2026-06-20",
  "returnDate": "2026-06-25"
}
```

### Availability Test

```text
GET /api/rentals/availability?vehicleId=1&rentDate=2026-06-21&returnDate=2026-06-24
```

## What I Learned

- How to design RESTful API endpoints with ASP.NET Core
- How to model relational data with Entity Framework Core
- How to use DTOs instead of taking entities directly from requests
- How to separate business logic into a service layer
- How to use repository pattern for data access
- How to register dependencies with dependency injection
- How to prepare a Code First migration structure for PostgreSQL
