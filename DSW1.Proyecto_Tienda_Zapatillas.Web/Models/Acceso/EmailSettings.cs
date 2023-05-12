namespace EncargoProyecto.Models
{
    public class EmailSettings
    {
        
            public string SmtpServer { get; set; } = string.Empty;
            public int SmtpPort { get; set; }
            public string Username { get; set; } = string.Empty;
            public string Password { get; set; } = string.Empty;

    }
}
