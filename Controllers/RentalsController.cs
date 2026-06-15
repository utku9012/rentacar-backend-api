using Microsoft.AspNetCore.Mvc;
using RentACarApi.DTOs;
using RentACarApi.Services;

namespace RentACarApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RentalsController : ControllerBase
{
    private readonly IRentalService _rentalService;

    public RentalsController(IRentalService rentalService)
    {
        _rentalService = rentalService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var rentals = await _rentalService.GetAllAsync();
        return Ok(rentals);
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateRentalDto dto)
    {
        var result = await _rentalService.CreateRentalAsync(dto);
        if (!result.IsSuccess)
        {
            return BadRequest(result.ErrorMessage);
        }

        return Ok(result.Rental);
    }

    [HttpGet("availability")]
    public async Task<IActionResult> CheckAvailability(
        int vehicleId,
        DateTime rentDate,
        DateTime returnDate)
    {
        var isAvailable = await _rentalService.IsVehicleAvailableAsync(vehicleId, rentDate, returnDate);
        return Ok(new { vehicleId, rentDate, returnDate, isAvailable });
    }
}
