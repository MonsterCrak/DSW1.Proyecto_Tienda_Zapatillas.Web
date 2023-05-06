using DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Acceso;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Security.Claims;

namespace DSW1.Proyecto_Tienda_Zapatillas.Web.Controllers
{
    public class AccesoController : Controller
    {
        public readonly IConfiguration? _configuration;

        public AccesoController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        //-----------------

        // Clientes

        //--Registro
        public IActionResult RegistroCliente()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult RegistroCliente(RegistroCliente usuario)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    using (SqlConnection cn = new SqlConnection(_configuration.GetConnectionString("cnDB")))
                    {
                        cn.Open();

                        using (SqlCommand cmd = new SqlCommand("sp_RegistrarUsuarioCliente", cn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;

                            cmd.Parameters.AddWithValue("@Nombre", usuario.Nombre);
                            cmd.Parameters.AddWithValue("@ApePaterno", usuario.ApePaterno);
                            cmd.Parameters.AddWithValue("@ApeMaterno", usuario.ApeMaterno);
                            cmd.Parameters.AddWithValue("@Email", usuario.Email);
                            cmd.Parameters.AddWithValue("@Clave", usuario.Clave);
                            cmd.Parameters.AddWithValue("@IdTipoUsuario", 1);
                            cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 100).Direction = ParameterDirection.Output;

                            cmd.ExecuteNonQuery();

                            string mensaje = cmd.Parameters["@Mensaje"].Value.ToString();


                            ViewBag.Mensaje = mensaje;

                            if (mensaje == "El usuario ha sido registrado exitosamente.")
                            {
                                return View("RegistroCliente");
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    ViewBag.Mensaje = "Ocurrió un error al intentar registrar al usuario. Por favor, inténtelo nuevamente.";
                }
            }



            return View(usuario);
        }
        //--Fin Registro

        //--Login

        public IActionResult IniciarSesionUsuarioCliente()
        {
            return View();
        }

        [HttpPost]
        public IActionResult IniciarSesionUsuarioCliente(SesionCliente usuario)
        {
            string mensaje;
            int? idUsuario;

            using (SqlConnection cn = new SqlConnection(_configuration.GetConnectionString("cnDB")))
            {
                cn.Open();
                var command = new SqlCommand("sp_IniciarSesionUsuarioCliente", cn);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Email", usuario.Email);
                command.Parameters.AddWithValue("@Clave", usuario.Clave);
                command.Parameters.Add("@Mensaje", SqlDbType.VarChar, 100).Direction = ParameterDirection.Output;
                command.Parameters.Add("@IdUsuario", SqlDbType.Int).Direction = ParameterDirection.Output;
                command.ExecuteNonQuery();
                mensaje = (string)command.Parameters["@Mensaje"].Value;
                idUsuario = command.Parameters["@IdUsuario"].Value == DBNull.Value ? null : (int?)command.Parameters["@IdUsuario"].Value;
            }

            ViewBag.Mensaje = mensaje;
            ViewBag.ID = idUsuario;

            if (ModelState.IsValid && idUsuario.HasValue)
            {
                return RedirectToAction("Index", "Cliente");
            }
            else
            {
                return View(usuario);
            }
        }

        //--Fin Login

        // Fin Clientes

        // Colaborador

        //--Registro

        public IActionResult RegistroColaborador()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult RegistroColaborador(RegistroColaborador usuario)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    using (SqlConnection cn = new SqlConnection(_configuration.GetConnectionString("cnDB")))
                    {
                        cn.Open();

                        using (SqlCommand cmd = new SqlCommand("sp_RegistrarUsuarioColaborador", cn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;

                            cmd.Parameters.AddWithValue("@Email", usuario.Email);
                            cmd.Parameters.AddWithValue("@Clave", usuario.Clave);
                            cmd.Parameters.AddWithValue("@DNI", usuario.DNI);
                            cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 100).Direction = ParameterDirection.Output;

                            cmd.ExecuteNonQuery();

                            string mensaje = cmd.Parameters["@Mensaje"].Value.ToString();


                            ViewBag.Mensaje = mensaje;

                            if (mensaje == "El usuario ha sido registrado exitosamente.")
                            {
                                return View("RegistroColaborador");
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    ViewBag.Mensaje = "Ocurrió un error al intentar registrar al usuario. Por favor, inténtelo nuevamente.";
                }
            }
            return View(usuario);
        }

        //--Fin Registro

        //--Login

        public IActionResult IniciarSesionUsuarioColaborador()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> IniciarSesionUsuarioColaborador(SesionColaborador usuario)
        {
            if (TempData.ContainsKey("Mensaje"))
            {
                ViewBag.Mensaje = TempData["Mensaje"];
            }

            string mensaje;

            using (SqlConnection cn = new SqlConnection(_configuration.GetConnectionString("cnDB")))
            {
                cn.Open();
                var command = new SqlCommand("sp_IniciarSesionUsuarioColaborador", cn);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Email", usuario.Email);
                command.Parameters.AddWithValue("@Clave", usuario.Clave);
                command.Parameters.Add("@Mensaje", SqlDbType.VarChar, 100).Direction = ParameterDirection.Output;
                command.ExecuteNonQuery();
                mensaje = (string)command.Parameters["@Mensaje"].Value;
            }

            if (mensaje.Contains("Inicio de sesión exitoso"))
            {
                var claims = new List<Claim>
        {
            new Claim(ClaimTypes.Name, usuario.Email)
        };

                var claimsIdentity = new ClaimsIdentity(
                    claims, CookieAuthenticationDefaults.AuthenticationScheme);

                var authProperties = new AuthenticationProperties
                {
                    ExpiresUtc = DateTimeOffset.UtcNow.AddMinutes(20),
                    IsPersistent = false,
                    IssuedUtc = DateTimeOffset.UtcNow
                };

                await HttpContext.SignInAsync(
                    CookieAuthenticationDefaults.AuthenticationScheme,
                    new ClaimsPrincipal(claimsIdentity),
                    authProperties);

                return RedirectToAction("Index", "Colaborador");
            }
            else
            {
                ViewBag.Mensaje = "Las credenciales especificadas son incorrectas.";
                ViewBag.Mensaje = mensaje;
                return View(usuario);
            }
        }


        //--Fin Login

        //--Logout
        public async Task<IActionResult> CerrarSesionColaborador()
        {
            await HttpContext.SignOutAsync(
                CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("IniciarSesionUsuarioColaborador", "Acceso");
        }



        //--Fin Logout

        //--Fin Colaborador
        //-----------------
    }
}
