using System.Text.Json.Serialization;

namespace RentACarApi.Entities;

public class Customer
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    [JsonIgnore]
    public ICollection<Rental> Rentals { get; set; } = new List<Rental>();
}
