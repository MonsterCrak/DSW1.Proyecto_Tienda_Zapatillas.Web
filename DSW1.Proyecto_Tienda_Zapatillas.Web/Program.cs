using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

// Agregados
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Acceso/IniciarSesionUsuarioColaborador";
        options.LogoutPath = "/Acceso/CerrarSesionColaborador";
    });

// Agregado de sesi�n
builder.Services.AddDistributedMemoryCache(); // Requerido para almacenar la sesi�n en memoria
builder.Services.AddSession(options =>
{
    // Configura las opciones de la sesi�n seg�n tus necesidades
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

// Agregados
app.UseAuthentication();
app.UseAuthorization();

// Agregado de sesi�n
app.UseSession();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Acceso}/{action=IniciarSesionUsuarioCliente}/{id?}");

app.Run();
