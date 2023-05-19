using DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Acceso;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Security.Claims;
using System.Diagnostics.Contracts;
using System.Net.Mail;
using System.Net;
using EncargoProyecto.Models;
using DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Cliente;
using Microsoft.AspNetCore.Http;
using System.Text.Json;


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
            if (!ModelState.IsValid)
            {
                return View(usuario);
            }

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
                        cmd.Parameters.Add("@IdUsuarioCliente", SqlDbType.Int).Direction = ParameterDirection.Output;


                        cmd.ExecuteNonQuery();

                        string mensaje = cmd.Parameters["@Mensaje"].Value.ToString();

                        if (mensaje == "El usuario ha sido registrado exitosamente.")
                        {
                            var Email = usuario.Email;
                            var Nombre = usuario.Nombre.ToString();
                            var ApellidoPat = usuario.ApePaterno.ToString();
                            var ApellidoMat = usuario.ApeMaterno.ToString();

                            var emailSettings = _configuration.GetSection("EmailSettings").Get<EmailSettings>();

                            var message = new MailMessage();
                            message.From = new MailAddress(emailSettings.Username);
                            message.To.Add(new MailAddress(Email));
                            message.Subject = "¡Bienvenido a TuZapatillaOnline!";
                            message.Body = $"Estimado/a {Nombre} {ApellidoPat} {ApellidoMat},\r\n\r\nQueremos darte la más cordial bienvenida a TuZapatillaOnline, la tienda en línea donde podrás encontrar una gran variedad de zapatillas para todas las ocasiones.\r\n\r\nNos complace que hayas decidido registrarte en nuestro sitio y confiar en nosotros para adquirir tus zapatillas. Estamos seguros de que encontrarás el modelo perfecto para ti entre nuestra amplia selección de marcas y estilos.\r\n\r\nAdemás, queremos informarte que con tu cuenta en TuZapatillaOnline podrás disfrutar de ventajas exclusivas como acceso a ofertas especiales, seguimiento de tus pedidos en línea y más.\r\n\r\nSi tienes alguna pregunta o necesitas ayuda en cualquier momento, no dudes en ponerte en contacto con nosotros a través de nuestro sitio web o correo electrónico.\r\n\r\n¡Gracias por formar parte de la comunidad de TuZapatillaOnline! Esperamos que tengas una excelente experiencia de compra con nosotros.\r\n\r\nSaludos cordiales,\r\n TuZapatillaOnline";

                            using (var client = new SmtpClient(emailSettings.SmtpServer, emailSettings.SmtpPort))
                            {
                                client.UseDefaultCredentials = false;
                                client.Credentials = new NetworkCredential(emailSettings.Username, emailSettings.Password);
                                client.EnableSsl = true;
                                client.Send(message);
                            }

                            ViewBag.Mensaje = mensaje;
                            ModelState.Clear();                           
                            return View("RegistroCliente");
                        }
                        else
                        {
                            ViewBag.Mensaje = mensaje;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ViewBag.Mensaje = "Ocurrió un error al intentar registrar al usuario. Por favor, inténtelo nuevamente."+ex.Message;
            }

            return View(usuario);

        }


        //--Fin Registro

        //--Login

        public IActionResult IniciarSesionUsuarioCliente()
        {
            return View("IniciarSesionUsuarioCliente");
        }

        [HttpPost]
        public IActionResult IniciarSesionUsuarioCliente(SesionCliente usuario)
        {
            string mensaje;
            int? idUsuario;

            if (!ModelState.IsValid)
            {
                return View(usuario);
            }

            using (SqlConnection cn = new SqlConnection(_configuration.GetConnectionString("cnDB")))
            {
                cn.Open();
                var command = new SqlCommand("sp_IniciarSesionUsuarioCliente", cn);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Email", string.IsNullOrWhiteSpace(usuario.Email) ? "" : usuario.Email);
                command.Parameters.AddWithValue("@Clave", string.IsNullOrWhiteSpace(usuario.Clave) ? "" : usuario.Clave);
                command.Parameters.Add("@Mensaje", SqlDbType.VarChar, 100).Direction = ParameterDirection.Output;
                command.Parameters.Add("@IdUsuario", SqlDbType.Int).Direction = ParameterDirection.Output;
                command.ExecuteNonQuery();
                mensaje = (string)command.Parameters["@Mensaje"].Value;
                idUsuario = command.Parameters["@IdUsuario"].Value == DBNull.Value ? null : (int?)command.Parameters["@IdUsuario"].Value;
            }

            ViewBag.Mensaje = mensaje;
            ViewBag.ID = idUsuario;

            if (idUsuario.HasValue)
            {
                Cliente cliente = new Cliente();
                {
                    cliente.IdCliente = idUsuario.Value;
                    cliente.IdUsuarioCliente = idUsuario.Value;
                };

                // Serializar el objeto cliente a JSON
                string clienteJson = JsonSerializer.Serialize(cliente);

                // Guardar los datos del usuario en la sesión
                HttpContext.Session.SetString("cliente", clienteJson);


                return RedirectToAction("Index", "Cliente");
            }

            return View(usuario);
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
                    using (SqlCommand cmd = new SqlCommand("sp_RegistrarUsuarioColaborador", cn))
                    {
                        cn.Open();
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
                            ModelState.Clear();
                            return View("RegistroColaborador");
                        }
                    }
                }
                catch
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
            string mensaje;
            if (!ModelState.IsValid)
            {
                return View(usuario);
            }

            using (SqlConnection cn = new SqlConnection(_configuration.GetConnectionString("cnDB")))
            {
                cn.Open();
                var command = new SqlCommand("sp_IniciarSesionUsuarioColaborador", cn);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Email", string.IsNullOrWhiteSpace(usuario.Email) ? "" : usuario.Email);
                command.Parameters.AddWithValue("@Clave", string.IsNullOrWhiteSpace(usuario.Clave) ? "" : usuario.Clave);
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
