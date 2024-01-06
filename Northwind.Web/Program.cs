using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Northwind.EntityModels;

#region Configure the web server host and services.

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorPages();
builder.Services.AddNorthwindContext();

var app = builder.Build();

#endregion

#region Configure the HTTP pipeline and routes

if (!app.Environment.IsDevelopment())
{
  app.UseHsts();
}

app.Use(async (HttpContext context, Func<Task> next) =>
{
  RouteEndpoint? rep = context.GetEndpoint() as RouteEndpoint;
  
  if (rep is not null)
  {
    WriteLine($"Endpoint name: {rep.DisplayName}");
    WriteLine($"Endpoint route pattern: {rep.RoutePattern.RawText}");
  }
  
  if (context.Request.Path == "/bonjour") 
  {
    await context.Response.WriteAsync("Bonjour Monde!");
    return;
  }
  
  // We could modify the request before calling the next delegate.
  await next();
  
  // We could nodify the reponse after calling the next delegate.
});

app.UseHttpsRedirection();

app.UseDefaultFiles(); // index.html, default.html, etc.
app.UseStaticFiles();

app.MapRazorPages();
app.MapGet("/hello", () => $"Environment is {app.Environment.EnvironmentName}");

#endregion

// Start the web server, host the website, and wait for requests.
app.Run();
WriteLine("This executes after the web server has stopped!");
