using System.Text.Json.Serialization;

namespace RentACarApi.Entities;

public class Branch
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    [JsonIgnore]
    public ICollection<Rental> Rentals { get; set; } = new List<Rental>();
}
