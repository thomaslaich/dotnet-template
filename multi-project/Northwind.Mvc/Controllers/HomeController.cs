using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore; // To use Include method.
using Northwind.EntityModels;
using Northwind.Mvc.Models;

namespace Northwind.Mvc.Controllers;

public class HomeController(ILogger<HomeController> logger, NorthwindContext db) : Controller
{
    private readonly ILogger<HomeController> _logger = logger;
    private readonly NorthwindContext _db = db;

    public IActionResult Index()
    {
        HomeIndexViewModel model =
            new(
                VisitorCount: Random.Shared.Next(1, 1001),
                Categories: _db.Categories.ToList(),
                Products: _db.Products.ToList()
            );

        return View(model);
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(
            new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier }
        );
    }

    public IActionResult ProductDetail(int? id)
    {
        if (!id.HasValue)
        {
            return BadRequest(
                "You must pass a product ID in the route, for example, /Home/ProductDetail/21"
            );
        }

        Product? model = _db.Products.Include(p => p.Category)
            .SingleOrDefault(p => p.ProductId == id);

        if (model is null)
        {
            return NotFound($"ProductId {id} not found.");
        }

        return View(model); // Pass model to view and then return result.
    }
}
