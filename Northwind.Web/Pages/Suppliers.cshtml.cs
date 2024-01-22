using Microsoft.AspNetCore.Mvc; // For [BindProperty] attribute
using Microsoft.AspNetCore.Mvc.RazorPages;
using Northwind.EntityModels;

namespace Northwind.Web.Pages;

public class SuppliersModel(NorthwindContext db) : PageModel
{
    private NorthwindContext _db = db;

    public IEnumerable<Supplier>? Suppliers { get; set; }

    public void OnGet()
    {
        ViewData["Title"] = "Northwind B2B - Suppliers";

        Suppliers = _db.Suppliers.OrderBy(s => s.Country).ThenBy(s => s.CompanyName);
    }

    [BindProperty]
    public Supplier? Supplier { get; set; }

    public IActionResult OnPost()
    {
        if (Supplier is not null && ModelState.IsValid)
        {
            _db.Suppliers.Add(Supplier);
            _db.SaveChanges();
            return RedirectToPage("/suppliers");
        }
        else
        {
            return Page();
        }
    }
}
