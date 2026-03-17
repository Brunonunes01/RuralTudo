abstract final class AppSchema {
  static const databaseName = 'ruraltudo.db';
  static const databaseVersion = 3;

  static const createStatements = <String>[
    '''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      description TEXT,
      created_at TEXT NOT NULL
    )
    ''',
    '''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      category_id INTEGER NOT NULL,
      product_type TEXT NOT NULL,
      unit TEXT NOT NULL,
      cost_price REAL NOT NULL,
      sale_price REAL NOT NULL,
      stock_quantity REAL NOT NULL DEFAULT 0,
      min_stock REAL NOT NULL DEFAULT 0,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY(category_id) REFERENCES categories(id)
    )
    ''',
    '''
    CREATE TABLE productions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL,
      production_type TEXT NOT NULL,
      quantity REAL NOT NULL,
      estimated_cost REAL,
      date TEXT NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY(product_id) REFERENCES products(id)
    )
    ''',
    '''
    CREATE TABLE stock_movements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL,
      movement_type TEXT NOT NULL,
      origin TEXT NOT NULL,
      quantity REAL NOT NULL,
      date TEXT NOT NULL,
      notes TEXT,
      reference_id INTEGER,
      created_at TEXT NOT NULL,
      FOREIGN KEY(product_id) REFERENCES products(id)
    )
    ''',
    '''
    CREATE TABLE customers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT,
      address TEXT,
      notes TEXT,
      created_at TEXT NOT NULL
    )
    ''',
    '''
    CREATE TABLE sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER,
      sale_date TEXT NOT NULL,
      total_amount REAL NOT NULL,
      payment_method TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'completed',
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY(customer_id) REFERENCES customers(id)
    )
    ''',
    '''
    CREATE TABLE sale_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL,
      quantity REAL NOT NULL,
      unit_price REAL NOT NULL,
      subtotal REAL NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY(sale_id) REFERENCES sales(id),
      FOREIGN KEY(product_id) REFERENCES products(id)
    )
    ''',
    '''
    CREATE TABLE expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL
    )
    ''',
    '''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER,
      description TEXT NOT NULL,
      total_value REAL NOT NULL,
      paid_signal REAL NOT NULL DEFAULT 0,
      order_date TEXT NOT NULL,
      expected_delivery_date TEXT,
      status TEXT NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY(customer_id) REFERENCES customers(id)
    )
    ''',
    '''
    CREATE TABLE order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER NOT NULL,
      product_id INTEGER,
      description TEXT,
      quantity REAL NOT NULL,
      unit_price REAL NOT NULL,
      subtotal REAL NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY(order_id) REFERENCES orders(id),
      FOREIGN KEY(product_id) REFERENCES products(id)
    )
    ''',
    '''
    CREATE TABLE settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      owner_name TEXT,
      farm_name TEXT,
      currency TEXT NOT NULL DEFAULT 'BRL',
      default_unit TEXT NOT NULL DEFAULT 'un',
      locale TEXT NOT NULL DEFAULT 'pt_BR',
      updated_at TEXT NOT NULL
    )
    ''',
    '''
    CREATE TABLE sync_queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      entity TEXT NOT NULL,
      operation TEXT NOT NULL,
      payload TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL,
      processed_at TEXT
    )
    ''',
    '''
    CREATE TABLE areas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      observations TEXT,
      area_m2 REAL,
      area_hectares REAL,
      perimeter REAL,
      polygon_points TEXT,
      notes TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    ''',
    '''
    CREATE TABLE plantings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      area_id INTEGER NOT NULL,
      crop_name TEXT NOT NULL,
      variety TEXT,
      planting_date TEXT NOT NULL,
      expected_harvest_date TEXT,
      cycle_days INTEGER,
      planted_quantity REAL,
      planted_unit TEXT,
      initial_cost REAL NOT NULL DEFAULT 0,
      notes TEXT,
      status TEXT NOT NULL DEFAULT 'planted',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY(area_id) REFERENCES areas(id)
    )
    ''',
    '''
    CREATE TABLE planting_managements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      planting_id INTEGER NOT NULL,
      management_type TEXT NOT NULL,
      date TEXT NOT NULL,
      cost REAL,
      description TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY(planting_id) REFERENCES plantings(id)
    )
    ''',
    '''
    CREATE TABLE harvests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      planting_id INTEGER NOT NULL,
      harvest_date TEXT NOT NULL,
      quantity REAL NOT NULL,
      unit TEXT NOT NULL,
      loss_quantity REAL,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY(planting_id) REFERENCES plantings(id)
    )
    ''',
    '''
    CREATE TABLE harvest_sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      harvest_id INTEGER NOT NULL,
      customer_id INTEGER,
      sale_date TEXT NOT NULL,
      quantity REAL NOT NULL,
      unit TEXT NOT NULL,
      unit_price REAL NOT NULL,
      total_amount REAL NOT NULL,
      payment_method TEXT NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY(harvest_id) REFERENCES harvests(id),
      FOREIGN KEY(customer_id) REFERENCES customers(id)
    )
    ''',
    '''
    CREATE TABLE farm_expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      planting_id INTEGER,
      category TEXT NOT NULL,
      description TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY(planting_id) REFERENCES plantings(id)
    )
    ''',
    '''
    CREATE TABLE modules_settings (
      module_key TEXT PRIMARY KEY,
      is_active INTEGER NOT NULL DEFAULT 1,
      updated_at TEXT NOT NULL
    )
    ''',
    '''
    CREATE TABLE app_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_mode TEXT NOT NULL DEFAULT 'agriculture',
      updated_at TEXT NOT NULL
    )
    ''',
    '''
    CREATE TABLE woodworking_orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER,
      item_name TEXT NOT NULL,
      quantity REAL NOT NULL,
      unit TEXT NOT NULL DEFAULT 'un',
      unit_price REAL,
      total_value REAL,
      order_date TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pendente',
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY(customer_id) REFERENCES customers(id)
    )
    ''',
    '''
    CREATE TABLE woodworking_sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER,
      sale_date TEXT NOT NULL,
      amount REAL NOT NULL,
      payment_method TEXT NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY(order_id) REFERENCES woodworking_orders(id)
    )
    ''',
  ];

  static const migrationToV2Statements = <String>[
    'CREATE TABLE IF NOT EXISTS areas (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, area_size REAL, area_unit TEXT, notes TEXT, is_active INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS plantings (id INTEGER PRIMARY KEY AUTOINCREMENT, area_id INTEGER NOT NULL, crop_name TEXT NOT NULL, variety TEXT, planting_date TEXT NOT NULL, expected_harvest_date TEXT, cycle_days INTEGER, planted_quantity REAL, planted_unit TEXT, initial_cost REAL NOT NULL DEFAULT 0, notes TEXT, status TEXT NOT NULL DEFAULT \'planted\', created_at TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY(area_id) REFERENCES areas(id))',
    'CREATE TABLE IF NOT EXISTS planting_managements (id INTEGER PRIMARY KEY AUTOINCREMENT, planting_id INTEGER NOT NULL, management_type TEXT NOT NULL, date TEXT NOT NULL, cost REAL, description TEXT, notes TEXT, created_at TEXT NOT NULL, FOREIGN KEY(planting_id) REFERENCES plantings(id))',
    'CREATE TABLE IF NOT EXISTS harvests (id INTEGER PRIMARY KEY AUTOINCREMENT, planting_id INTEGER NOT NULL, harvest_date TEXT NOT NULL, quantity REAL NOT NULL, unit TEXT NOT NULL, loss_quantity REAL, notes TEXT, created_at TEXT NOT NULL, FOREIGN KEY(planting_id) REFERENCES plantings(id))',
    'CREATE TABLE IF NOT EXISTS harvest_sales (id INTEGER PRIMARY KEY AUTOINCREMENT, harvest_id INTEGER NOT NULL, customer_id INTEGER, sale_date TEXT NOT NULL, quantity REAL NOT NULL, unit TEXT NOT NULL, unit_price REAL NOT NULL, total_amount REAL NOT NULL, payment_method TEXT NOT NULL, notes TEXT, created_at TEXT NOT NULL, FOREIGN KEY(harvest_id) REFERENCES harvests(id), FOREIGN KEY(customer_id) REFERENCES customers(id))',
    'CREATE TABLE IF NOT EXISTS farm_expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, planting_id INTEGER, category TEXT NOT NULL, description TEXT NOT NULL, amount REAL NOT NULL, date TEXT NOT NULL, notes TEXT, created_at TEXT NOT NULL, FOREIGN KEY(planting_id) REFERENCES plantings(id))',
    'CREATE TABLE IF NOT EXISTS modules_settings (module_key TEXT PRIMARY KEY, is_active INTEGER NOT NULL DEFAULT 1, updated_at TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS app_settings (id INTEGER PRIMARY KEY AUTOINCREMENT, profile_mode TEXT NOT NULL DEFAULT \'agriculture\', updated_at TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS woodworking_orders (id INTEGER PRIMARY KEY AUTOINCREMENT, customer_id INTEGER, item_name TEXT NOT NULL, quantity REAL NOT NULL, unit TEXT NOT NULL DEFAULT \'un\', unit_price REAL, total_value REAL, order_date TEXT NOT NULL, status TEXT NOT NULL DEFAULT \'pendente\', notes TEXT, created_at TEXT NOT NULL, FOREIGN KEY(customer_id) REFERENCES customers(id))',
    'CREATE TABLE IF NOT EXISTS woodworking_sales (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER, sale_date TEXT NOT NULL, amount REAL NOT NULL, payment_method TEXT NOT NULL, notes TEXT, created_at TEXT NOT NULL, FOREIGN KEY(order_id) REFERENCES woodworking_orders(id))',
  ];

  static const migrationToV3Statements = <String>[
    'ALTER TABLE areas ADD COLUMN observations TEXT',
    'ALTER TABLE areas ADD COLUMN area_m2 REAL',
    'ALTER TABLE areas ADD COLUMN area_hectares REAL',
    'ALTER TABLE areas ADD COLUMN perimeter REAL',
    'ALTER TABLE areas ADD COLUMN polygon_points TEXT',
    "UPDATE areas SET area_m2 = CASE WHEN area_unit = 'ha' OR area_unit = 'HA' THEN COALESCE(area_size, 0) * 10000 ELSE area_size END WHERE area_m2 IS NULL",
    "UPDATE areas SET area_hectares = CASE WHEN area_m2 IS NULL THEN NULL ELSE area_m2 / 10000 END WHERE area_hectares IS NULL",
  ];
}
