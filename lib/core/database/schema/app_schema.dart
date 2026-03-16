abstract final class AppSchema {
  static const databaseName = 'ruraltudo.db';
  static const databaseVersion = 1;

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
  ];
}
