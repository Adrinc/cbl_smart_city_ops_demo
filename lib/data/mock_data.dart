/// Mock data for CBLuna Dashboard Demos
/// All data is hardcoded and lives only in memory during the session
/// NO backend connections, NO authentication, NO persistence
library;

/// ============================================================================
/// SALES DASHBOARD DATA
/// ============================================================================

class SalesSummary {
  final double totalRevenue;
  final int totalClients;
  final int totalSales;
  final double averageTicket;
  final double monthlyGrowth;

  SalesSummary({
    required this.totalRevenue,
    required this.totalClients,
    required this.totalSales,
    required this.averageTicket,
    required this.monthlyGrowth,
  });
}

final mockSalesSummary = SalesSummary(
  totalRevenue: 1250000.00,
  totalClients: 342,
  totalSales: 1850,
  averageTicket: 675.68,
  monthlyGrowth: 12.5,
);

class SalesDataPoint {
  final String month;
  final double value;

  SalesDataPoint(this.month, this.value);
}

final List<SalesDataPoint> mockMonthlySales = [
  SalesDataPoint('Ene', 95000),
  SalesDataPoint('Feb', 105000),
  SalesDataPoint('Mar', 98000),
  SalesDataPoint('Abr', 120000),
  SalesDataPoint('May', 135000),
  SalesDataPoint('Jun', 125000),
];

/// ============================================================================
/// VIDEO CONTENT DASHBOARD DATA
/// ============================================================================

class VideoStats {
  final int totalViews;
  final int subscribers;
  final int totalVideos;
  final double avgWatchTime;
  final double engagement;

  VideoStats({
    required this.totalViews,
    required this.subscribers,
    required this.totalVideos,
    required this.avgWatchTime,
    required this.engagement,
  });
}

final mockVideoStats = VideoStats(
  totalViews: 2500000,
  subscribers: 45000,
  totalVideos: 156,
  avgWatchTime: 8.5,
  engagement: 6.2,
);

class TopVideo {
  final String title;
  final int views;
  final String duration;

  TopVideo(this.title, this.views, this.duration);
}

final List<TopVideo> mockTopVideos = [
  TopVideo('Tutorial Flutter Avanzado', 125000, '15:30'),
  TopVideo('Diseño UI/UX Moderno', 98000, '12:45'),
  TopVideo('Dashboard con Flutter', 87000, '18:20'),
  TopVideo('State Management Provider', 76000, '22:15'),
  TopVideo('Responsive Design Tips', 65000, '10:30'),
];

class VideoCategory {
  final String name;
  final int videoCount;
  final int views;

  VideoCategory(this.name, this.videoCount, this.views);
}

final List<VideoCategory> mockVideoCategories = [
  VideoCategory('Tutoriales', 45, 850000),
  VideoCategory('Reviews', 32, 620000),
  VideoCategory('Tips & Tricks', 28, 480000),
];

/// Client model
class Client {
  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final String status; // 'Activo', 'Inactivo', 'Prospecto'
  final String responsible;
  final DateTime lastContact;
  final String notes;

  Client({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.status,
    required this.responsible,
    required this.lastContact,
    this.notes = '',
  });

  Client copyWith({
    String? id,
    String? name,
    String? company,
    String? email,
    String? phone,
    String? status,
    String? responsible,
    DateTime? lastContact,
    String? notes,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      responsible: responsible ?? this.responsible,
      lastContact: lastContact ?? this.lastContact,
      notes: notes ?? this.notes,
    );
  }
}

/// Employee model
class Employee {
  final String id;
  final String name;
  final String email;
  final String role; // 'Admin', 'Vendedor', 'Soporte', 'Marketing'
  final String area; // 'Ventas', 'Marketing', 'Soporte', 'Administración'
  final String status; // 'Activo', 'Inactivo'
  final DateTime hireDate;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.area,
    required this.status,
    required this.hireDate,
  });
}

/// Activity model
class Activity {
  final String id;
  final String type; // 'Llamada', 'Reunión', 'Email', 'Tarea', 'Nota'
  final String description;
  final String clientName;
  final String responsible;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.type,
    required this.description,
    required this.clientName,
    required this.responsible,
    required this.timestamp,
  });
}

/// Mock clients data (20-30 records)
final List<Client> mockClients = [
  Client(
    id: 'client-001',
    name: 'Juan Pérez',
    company: 'Innovatech Solutions',
    email: 'juan.perez@innovatech.com',
    phone: '+52 55 1234 5678',
    status: 'Activo',
    responsible: 'Carlos Mendoza',
    lastContact: DateTime.now().subtract(const Duration(days: 2)),
    notes: 'Cliente premium, requiere atención personalizada',
  ),
  Client(
    id: 'client-002',
    name: 'María González',
    company: 'TechStart México',
    email: 'maria.gonzalez@techstart.mx',
    phone: '+52 33 9876 5432',
    status: 'Activo',
    responsible: 'Ana Torres',
    lastContact: DateTime.now().subtract(const Duration(days: 5)),
    notes: 'Interesada en plan enterprise',
  ),
  Client(
    id: 'client-003',
    name: 'Roberto Sánchez',
    company: 'Digital Marketing Pro',
    email: 'roberto.sanchez@dmpro.com',
    phone: '+52 81 5555 1234',
    status: 'Prospecto',
    responsible: 'Carlos Mendoza',
    lastContact: DateTime.now().subtract(const Duration(days: 1)),
    notes: 'Solicitó demo del producto',
  ),
  Client(
    id: 'client-004',
    name: 'Laura Martínez',
    company: 'Constructora Moderna',
    email: 'laura.martinez@constmoderna.com',
    phone: '+52 55 4444 7890',
    status: 'Activo',
    responsible: 'Ana Torres',
    lastContact: DateTime.now().subtract(const Duration(days: 8)),
  ),
  Client(
    id: 'client-005',
    name: 'Carlos Ramírez',
    company: 'Logística Express',
    email: 'carlos.ramirez@logexpress.com',
    phone: '+52 33 7777 8888',
    status: 'Activo',
    responsible: 'Luis Romero',
    lastContact: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Client(
    id: 'client-006',
    name: 'Ana López',
    company: 'Retail Solutions',
    email: 'ana.lopez@retailsol.mx',
    phone: '+52 81 2222 3333',
    status: 'Inactivo',
    responsible: 'Carlos Mendoza',
    lastContact: DateTime.now().subtract(const Duration(days: 45)),
    notes: 'Pausó contrato temporalmente',
  ),
  Client(
    id: 'client-007',
    name: 'Fernando Torres',
    company: 'CloudTech Services',
    email: 'fernando.torres@cloudtech.com',
    phone: '+52 55 9999 0000',
    status: 'Activo',
    responsible: 'Ana Torres',
    lastContact: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Client(
    id: 'client-008',
    name: 'Patricia Hernández',
    company: 'Finanzas Corporativas',
    email: 'patricia.hernandez@fincorp.mx',
    phone: '+52 33 1111 2222',
    status: 'Prospecto',
    responsible: 'Luis Romero',
    lastContact: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  Client(
    id: 'client-009',
    name: 'Miguel Ángel Cruz',
    company: 'Desarrollos Inmobiliarios',
    email: 'miguel.cruz@desinm.com',
    phone: '+52 81 6666 7777',
    status: 'Activo',
    responsible: 'Carlos Mendoza',
    lastContact: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Client(
    id: 'client-010',
    name: 'Gabriela Moreno',
    company: 'E-Commerce Plus',
    email: 'gabriela.moreno@ecomplus.mx',
    phone: '+52 55 3333 4444',
    status: 'Activo',
    responsible: 'Ana Torres',
    lastContact: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Client(
    id: 'client-011',
    name: 'Ricardo Vega',
    company: 'Consultoría Estratégica',
    email: 'ricardo.vega@consulest.com',
    phone: '+52 33 8888 9999',
    status: 'Activo',
    responsible: 'Luis Romero',
    lastContact: DateTime.now().subtract(const Duration(days: 10)),
  ),
  Client(
    id: 'client-012',
    name: 'Sofía Jiménez',
    company: 'Marketing Digital 360',
    email: 'sofia.jimenez@md360.mx',
    phone: '+52 81 4444 5555',
    status: 'Prospecto',
    responsible: 'Carlos Mendoza',
    lastContact: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Client(
    id: 'client-013',
    name: 'Diego Castillo',
    company: 'Soluciones Empresariales',
    email: 'diego.castillo@solemp.com',
    phone: '+52 55 7777 8888',
    status: 'Activo',
    responsible: 'Ana Torres',
    lastContact: DateTime.now().subtract(const Duration(days: 6)),
  ),
  Client(
    id: 'client-014',
    name: 'Valeria Ruiz',
    company: 'Tech Innovations Lab',
    email: 'valeria.ruiz@techinnolab.mx',
    phone: '+52 33 5555 6666',
    status: 'Activo',
    responsible: 'Luis Romero',
    lastContact: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Client(
    id: 'client-015',
    name: 'Andrés Mendoza',
    company: 'Servicios Profesionales',
    email: 'andres.mendoza@servprof.com',
    phone: '+52 81 1111 2222',
    status: 'Inactivo',
    responsible: 'Carlos Mendoza',
    lastContact: DateTime.now().subtract(const Duration(days: 60)),
  ),
  Client(
    id: 'client-016',
    name: 'Carolina Silva',
    company: 'Diseño y Creatividad',
    email: 'carolina.silva@disenocrea.mx',
    phone: '+52 55 2222 3333',
    status: 'Activo',
    responsible: 'Ana Torres',
    lastContact: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Client(
    id: 'client-017',
    name: 'Javier Ortiz',
    company: 'Automatización Industrial',
    email: 'javier.ortiz@autind.com',
    phone: '+52 33 6666 7777',
    status: 'Activo',
    responsible: 'Luis Romero',
    lastContact: DateTime.now().subtract(const Duration(days: 9)),
  ),
  Client(
    id: 'client-018',
    name: 'Daniela Flores',
    company: 'Healthcare Solutions',
    email: 'daniela.flores@healthsol.mx',
    phone: '+52 81 8888 9999',
    status: 'Prospecto',
    responsible: 'Carlos Mendoza',
    lastContact: DateTime.now().subtract(const Duration(hours: 12)),
  ),
  Client(
    id: 'client-019',
    name: 'Alejandro Navarro',
    company: 'Logística Inteligente',
    email: 'alejandro.navarro@logint.com',
    phone: '+52 55 4444 5555',
    status: 'Activo',
    responsible: 'Ana Torres',
    lastContact: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Client(
    id: 'client-020',
    name: 'Isabella Rojas',
    company: 'StartUp Accelerator',
    email: 'isabella.rojas@startupaccel.mx',
    phone: '+52 33 9999 0000',
    status: 'Activo',
    responsible: 'Luis Romero',
    lastContact: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Client(
    id: 'client-021',
    name: 'Héctor Vargas',
    company: 'Energías Renovables',
    email: 'hector.vargas@enrenovables.com',
    phone: '+52 81 3333 4444',
    status: 'Activo',
    responsible: 'Carlos Mendoza',
    lastContact: DateTime.now().subtract(const Duration(days: 11)),
  ),
  Client(
    id: 'client-022',
    name: 'Camila Reyes',
    company: 'Asesoría Legal Pro',
    email: 'camila.reyes@aselegalpro.mx',
    phone: '+52 55 6666 7777',
    status: 'Prospecto',
    responsible: 'Ana Torres',
    lastContact: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Client(
    id: 'client-023',
    name: 'Sebastián Delgado',
    company: 'Software Factory',
    email: 'sebastian.delgado@softfactory.com',
    phone: '+52 33 2222 3333',
    status: 'Activo',
    responsible: 'Luis Romero',
    lastContact: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Client(
    id: 'client-024',
    name: 'Mariana Castro',
    company: 'Capacitación Empresarial',
    email: 'mariana.castro@capaemp.mx',
    phone: '+52 81 5555 6666',
    status: 'Activo',
    responsible: 'Carlos Mendoza',
    lastContact: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Client(
    id: 'client-025',
    name: 'Pablo Morales',
    company: 'Arquitectura Moderna',
    email: 'pablo.morales@arquimod.com',
    phone: '+52 55 8888 9999',
    status: 'Activo',
    responsible: 'Ana Torres',
    lastContact: DateTime.now().subtract(const Duration(days: 6)),
  ),
];

/// Mock employees data (10-15 records)
final List<Employee> mockEmployees = [
  Employee(
    id: 'emp-001',
    name: 'Carlos Mendoza',
    email: 'carlos.mendoza@democorp.com',
    role: 'Vendedor Senior',
    area: 'Ventas',
    status: 'Activo',
    hireDate: DateTime(2022, 3, 15),
  ),
  Employee(
    id: 'emp-002',
    name: 'Ana Torres',
    email: 'ana.torres@democorp.com',
    role: 'Vendedor',
    area: 'Ventas',
    status: 'Activo',
    hireDate: DateTime(2023, 1, 10),
  ),
  Employee(
    id: 'emp-003',
    name: 'Luis Romero',
    email: 'luis.romero@democorp.com',
    role: 'Vendedor',
    area: 'Ventas',
    status: 'Activo',
    hireDate: DateTime(2023, 6, 20),
  ),
  Employee(
    id: 'emp-004',
    name: 'María Fernanda López',
    email: 'mf.lopez@democorp.com',
    role: 'Gerente de Ventas',
    area: 'Ventas',
    status: 'Activo',
    hireDate: DateTime(2021, 8, 5),
  ),
  Employee(
    id: 'emp-005',
    name: 'Roberto González',
    email: 'roberto.gonzalez@democorp.com',
    role: 'Especialista en Marketing',
    area: 'Marketing',
    status: 'Activo',
    hireDate: DateTime(2022, 11, 12),
  ),
  Employee(
    id: 'emp-006',
    name: 'Sandra Martínez',
    email: 'sandra.martinez@democorp.com',
    role: 'Coordinador de Marketing',
    area: 'Marketing',
    status: 'Activo',
    hireDate: DateTime(2023, 2, 28),
  ),
  Employee(
    id: 'emp-007',
    name: 'José Luis Ramírez',
    email: 'joseluis.ramirez@democorp.com',
    role: 'Soporte Técnico',
    area: 'Soporte',
    status: 'Activo',
    hireDate: DateTime(2023, 4, 15),
  ),
  Employee(
    id: 'emp-008',
    name: 'Lucía Hernández',
    email: 'lucia.hernandez@democorp.com',
    role: 'Soporte Técnico',
    area: 'Soporte',
    status: 'Activo',
    hireDate: DateTime(2023, 7, 1),
  ),
  Employee(
    id: 'emp-009',
    name: 'Pedro Sánchez',
    email: 'pedro.sanchez@democorp.com',
    role: 'Administrador de Sistemas',
    area: 'Administración',
    status: 'Activo',
    hireDate: DateTime(2021, 5, 20),
  ),
  Employee(
    id: 'emp-010',
    name: 'Admin Demo',
    email: 'admin@democorp.com',
    role: 'Administrador',
    area: 'Administración',
    status: 'Activo',
    hireDate: DateTime(2021, 1, 1),
  ),
  Employee(
    id: 'emp-011',
    name: 'Elena Jiménez',
    email: 'elena.jimenez@democorp.com',
    role: 'Recursos Humanos',
    area: 'Administración',
    status: 'Activo',
    hireDate: DateTime(2022, 9, 10),
  ),
  Employee(
    id: 'emp-012',
    name: 'Miguel Torres',
    email: 'miguel.torres@democorp.com',
    role: 'Contador',
    area: 'Administración',
    status: 'Activo',
    hireDate: DateTime(2022, 7, 25),
  ),
];

/// Mock activities data
final List<Activity> mockActivities = [
  Activity(
    id: 'act-001',
    type: 'Llamada',
    description: 'Seguimiento de propuesta comercial',
    clientName: 'Juan Pérez - Innovatech Solutions',
    responsible: 'Carlos Mendoza',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Activity(
    id: 'act-002',
    type: 'Reunión',
    description: 'Demo del producto',
    clientName: 'Roberto Sánchez - Digital Marketing Pro',
    responsible: 'Carlos Mendoza',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  Activity(
    id: 'act-003',
    type: 'Email',
    description: 'Envío de cotización',
    clientName: 'María González - TechStart México',
    responsible: 'Ana Torres',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
  ),
  Activity(
    id: 'act-004',
    type: 'Tarea',
    description: 'Preparar presentación ejecutiva',
    clientName: 'Patricia Hernández - Finanzas Corporativas',
    responsible: 'Luis Romero',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Activity(
    id: 'act-005',
    type: 'Llamada',
    description: 'Check-in mensual',
    clientName: 'Fernando Torres - CloudTech Services',
    responsible: 'Ana Torres',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  ),
  Activity(
    id: 'act-006',
    type: 'Reunión',
    description: 'Renovación de contrato',
    clientName: 'Laura Martínez - Constructora Moderna',
    responsible: 'Ana Torres',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Activity(
    id: 'act-007',
    type: 'Email',
    description: 'Resolución de dudas técnicas',
    clientName: 'Carlos Ramírez - Logística Express',
    responsible: 'Luis Romero',
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
  ),
  Activity(
    id: 'act-008',
    type: 'Nota',
    description: 'Cliente solicitó información adicional',
    clientName: 'Daniela Flores - Healthcare Solutions',
    responsible: 'Carlos Mendoza',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

/// Dashboard KPIs
class DashboardKPIs {
  static const int activeClients = 247;
  static const int openOpportunities = 32;
  static const int monthlyActivities = 156;
  static const String estimatedSales = '\$284,500';
  static const double conversionRate = 68.5;
  static const int newClientsThisMonth = 8;
  static const int pendingTasks = 15;
}

/// Chart data for dashboard
class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}

/// Activity data for last 7 days (for charts)
final List<ChartData> mockActivityChartData = [
  ChartData('Lun', 18),
  ChartData('Mar', 24),
  ChartData('Mié', 22),
  ChartData('Jue', 28),
  ChartData('Vie', 20),
  ChartData('Sáb', 8),
  ChartData('Dom', 5),
];

/// Clients by status (for pie chart)
final List<ChartData> mockClientsByStatus = [
  ChartData('Activos', 19),
  ChartData('Prospectos', 4),
  ChartData('Inactivos', 2),
];
