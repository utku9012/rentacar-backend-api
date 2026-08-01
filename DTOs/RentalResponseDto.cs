namespace RentACarApi.DTOs;

public class RentalResponseDto
{
    public int Id { get; set; }
    public string CustomerFullName { get; set; } = string.Empty;
    public string VehicleName { get; set; } = string.Empty;
    public string BranchName { get; set; } = string.Empty;
    public DateTime RentDate { get; set; }
    public DateTime ReturnDate { get; set; }
    public decimal TotalAmount { get; set; }
}
