using Microsoft.AspNetCore.Mvc;
using RentACarApi.DTOs;
using RentACarApi.Entities;
using RentACarApi.Repositories;

namespace RentACarApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class VehiclesController : ControllerBase
{
    private readonly IVehicleRepository _vehicleRepository;

    public VehiclesController(IVehicleRepository vehicleRepository)
    {
        _vehicleRepository = vehicleRepository;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var vehicles = await _vehicleRepository.GetAllAsync();
        return Ok(vehicles);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var vehicle = await _vehicleRepository.GetByIdAsync(id);
        if (vehicle is null)
        {
            return NotFound();
        }

        return Ok(vehicle);
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateVehicleDto dto)
    {
        var vehicle = new Vehicle
        {
            Brand = dto.Brand,
            Model = dto.Model,
            ModelYear = dto.ModelYear,
            PlateNumber = dto.PlateNumber,
            VehicleTypeId = dto.VehicleTypeId
        };

        await _vehicleRepository.AddAsync(vehicle);
        await _vehicleRepository.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = vehicle.Id }, vehicle);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, CreateVehicleDto dto)
    {
        var vehicle = await _vehicleRepository.GetByIdAsync(id);
        if (vehicle is null)
        {
            return NotFound();
        }

        vehicle.Brand = dto.Brand;
        vehicle.Model = dto.Model;
        vehicle.ModelYear = dto.ModelYear;
        vehicle.PlateNumber = dto.PlateNumber;
        vehicle.VehicleTypeId = dto.VehicleTypeId;

        _vehicleRepository.Update(vehicle);
        await _vehicleRepository.SaveChangesAsync();

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var vehicle = await _vehicleRepository.GetByIdAsync(id);
        if (vehicle is null)
        {
            return NotFound();
        }

        _vehicleRepository.Delete(vehicle);
        await _vehicleRepository.SaveChangesAsync();

        return NoContent();
    }
}
