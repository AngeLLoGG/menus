//
//  SampleData.swift
//  AtelierBistro
//
//  Datos de ejemplo idénticos a los del prototipo: carta de Atelier Bistro,
//  modificadores por plato y comandas iniciales de cocina.
//

import Foundation

enum SampleData {

    // MARK: - Categorías de la carta

    static let categories: [MenuCategory] = [
        MenuCategory(id: "all", name: "Todo"),
        MenuCategory(id: "entrantes", name: "Entrantes"),
        MenuCategory(id: "principales", name: "Principales"),
        MenuCategory(id: "carnes", name: "Brasa y Carnes"),
        MenuCategory(id: "postres", name: "Postres"),
        MenuCategory(id: "bebidas", name: "Bebidas & Vinos")
    ]

    // MARK: - Carta

    static let products: [Product] = [
        Product(
            id: "p-1",
            categoryId: "entrantes",
            name: "Tartar de Salmón & Aguacate",
            description: "Salmón fresco noruego picado a cuchillo, emulsión de cítricos, cebolleta y sésamo negro tostado.",
            price: 14.50,
            isAvailable: true,
            modifiers: [
                ModifierGroup(
                    id: "mod-dressing",
                    name: "Aderezo Cítrico",
                    isRequired: true,
                    kind: .single,
                    options: [
                        ModifierOption(id: "opt-d1", name: "Ponzu y Lima (Recomendado)", price: 0),
                        ModifierOption(id: "opt-d2", name: "Aceite de Oliva Virgen Extra & Sal marina", price: 0),
                        ModifierOption(id: "opt-d3", name: "Picante suave de Chiles Fermentados", price: 0.50)
                    ]
                ),
                ModifierGroup(
                    id: "mod-extras-salmon",
                    name: "Complementos",
                    isRequired: false,
                    kind: .multiple,
                    options: [
                        ModifierOption(id: "opt-e1", name: "Extra de Tostas finas de centeno (4 uds)", price: 1.50),
                        ModifierOption(id: "opt-e2", name: "Alcaparras fritas crujientes", price: 0.80),
                        ModifierOption(id: "opt-e3", name: "Doble ración de Aguacate hass", price: 2.00)
                    ]
                )
            ]
        ),
        Product(
            id: "p-2",
            categoryId: "entrantes",
            name: "Burrata de Puglia & Higos Confitados",
            description: "Burrata artesanal de 200g, higos al vino dulce, rúcula salvaje y reducción balsámica de Módena de 12 años.",
            price: 13.00,
            isAvailable: true,
            modifiers: [
                ModifierGroup(
                    id: "mod-burrata-bread",
                    name: "Acompañamiento de Pan",
                    isRequired: true,
                    kind: .single,
                    options: [
                        ModifierOption(id: "opt-b1", name: "Focaccia artesanal de romero", price: 0),
                        ModifierOption(id: "opt-b2", name: "Pan de masa madre tostado", price: 0),
                        ModifierOption(id: "opt-b3", name: "Sin gluten (tostadas de maíz)", price: 1.00)
                    ]
                ),
                ModifierGroup(
                    id: "mod-burrata-extras",
                    name: "Añadidos Gourmet",
                    isRequired: false,
                    kind: .multiple,
                    options: [
                        ModifierOption(id: "opt-be1", name: "Láminas de Jamón Ibérico de Bellota (50g)", price: 4.50),
                        ModifierOption(id: "opt-be2", name: "Pesto de albahaca fresca casero", price: 1.50)
                    ]
                )
            ]
        ),
        Product(
            id: "p-3",
            categoryId: "principales",
            name: "Risotto de Boletus & Trufa Negra",
            description: "Arroz Carnaroli mantecado con Parmigiano Reggiano 24 meses, boletus edulis salteados y perlas de trufa melanosporum.",
            price: 18.50,
            isAvailable: true,
            modifiers: [
                ModifierGroup(
                    id: "mod-risotto-cheese",
                    name: "Punto de Parmigiano",
                    isRequired: true,
                    kind: .single,
                    options: [
                        ModifierOption(id: "opt-r1", name: "Tradicional mantecado", price: 0),
                        ModifierOption(id: "opt-r2", name: "Poco queso / Ligero", price: 0)
                    ]
                ),
                ModifierGroup(
                    id: "mod-risotto-extras",
                    name: "Extras",
                    isRequired: false,
                    kind: .multiple,
                    options: [
                        ModifierOption(id: "opt-re1", name: "Láminas de trufa negra fresca de temporada", price: 5.00),
                        ModifierOption(id: "opt-re2", name: "Foie micuit marcado a la plancha", price: 4.00)
                    ]
                )
            ]
        ),
        Product(
            id: "p-4",
            categoryId: "principales",
            name: "Lubina Salvaje a la Espalda",
            description: "Lomo de lubina salvaje confitada a baja temperatura, bilbaína clásica suave de ajo y emulsión de patata ratte.",
            price: 22.00,
            isAvailable: true,
            modifiers: [
                ModifierGroup(
                    id: "mod-fish-cook",
                    name: "Punto de Cocción",
                    isRequired: true,
                    kind: .single,
                    options: [
                        ModifierOption(id: "opt-fc1", name: "Punto jugoso (Recomendado)", price: 0),
                        ModifierOption(id: "opt-fc2", name: "Bien cocido", price: 0)
                    ]
                )
            ]
        ),
        Product(
            id: "p-5",
            categoryId: "carnes",
            name: "Solomillo de Vaca Madurada (250g)",
            description: "Corte seleccionado de vaca frisona con 45 días de maduración dry-aged, cristales de sal Maldon y chalotas glaseadas.",
            price: 26.50,
            isAvailable: true,
            modifiers: [
                ModifierGroup(
                    id: "mod-meat-doneness",
                    name: "Término de la Carne",
                    isRequired: true,
                    kind: .single,
                    options: [
                        ModifierOption(id: "opt-m1", name: "Poco hecho (Bleu)", price: 0),
                        ModifierOption(id: "opt-m2", name: "Al punto (Medium rare)", price: 0),
                        ModifierOption(id: "opt-m3", name: "Punto más (Medium well)", price: 0),
                        ModifierOption(id: "opt-m4", name: "Muy hecho", price: 0)
                    ]
                ),
                ModifierGroup(
                    id: "mod-meat-garnish",
                    name: "Guarnición Principal",
                    isRequired: true,
                    kind: .single,
                    options: [
                        ModifierOption(id: "opt-g1", name: "Patatas baby asadas con romero", price: 0),
                        ModifierOption(id: "opt-g2", name: "Pimientos del piquillo confitados a leña", price: 1.00),
                        ModifierOption(id: "opt-g3", name: "Ensalada de brotes y vinagreta de mostaza antigua", price: 0)
                    ]
                ),
                ModifierGroup(
                    id: "mod-meat-sauce",
                    name: "Salsas Artesanales",
                    isRequired: false,
                    kind: .multiple,
                    options: [
                        ModifierOption(id: "opt-s1", name: "Salsa de pimienta verde de Madagascar", price: 1.80),
                        ModifierOption(id: "opt-s2", name: "Mantequilla Café de París especiada", price: 2.00)
                    ]
                )
            ]
        ),
        Product(
            id: "p-6",
            categoryId: "carnes",
            name: "Costillar Ibérico Glaseado",
            description: "Costillas de cerdo ibérico cocidas durante 18 horas a baja temperatura con glaseado de miel de brezo y tomillo silvestre.",
            price: 19.50,
            isAvailable: false,
            modifiers: []
        ),
        Product(
            id: "p-7",
            categoryId: "postres",
            name: "Cremoso de Chocolate 70% & Sal de Añana",
            description: "Ganache aireada de cacao ecológico origen Guanaja, núcleo líquido de avellana piamontesa y AOVE arbequina.",
            price: 7.50,
            isAvailable: true,
            modifiers: [
                ModifierGroup(
                    id: "mod-dessert-icecream",
                    name: "Bola de Helado Artesano",
                    isRequired: false,
                    kind: .single,
                    options: [
                        ModifierOption(id: "opt-i0", name: "Sin helado adicional", price: 0),
                        ModifierOption(id: "opt-i1", name: "Helado de Vainilla bourbon de Madagascar", price: 2.00),
                        ModifierOption(id: "opt-i2", name: "Sorbete de Frambuesa silvestre", price: 2.00)
                    ]
                )
            ]
        ),
        Product(
            id: "p-8",
            categoryId: "bebidas",
            name: "Vino Tinto Ribera del Duero Crianza (Copa)",
            description: "100% Tempranillo, 14 meses en barrica de roble francés. Notas de frutos negros maduros y cedro.",
            price: 4.80,
            isAvailable: true,
            modifiers: []
        ),
        Product(
            id: "p-9",
            categoryId: "bebidas",
            name: "Agua Mineral de Manantial (750ml)",
            description: "Botella de vidrio retornable, agua de mineralización muy débil de origen alpino.",
            price: 3.20,
            isAvailable: true,
            modifiers: [
                ModifierGroup(
                    id: "mod-water-type",
                    name: "Tipo de Agua",
                    isRequired: true,
                    kind: .single,
                    options: [
                        ModifierOption(id: "opt-w1", name: "Natural sin gas (Fría)", price: 0),
                        ModifierOption(id: "opt-w2", name: "Natural sin gas (Tiempo)", price: 0),
                        ModifierOption(id: "opt-w3", name: "Con gas carbónico fino natural", price: 0.30)
                    ]
                )
            ]
        )
    ]

    // MARK: - Comandas iniciales del KDS

    /// Comandas de arranque. `now` permite fijar los cronómetros del prototipo
    /// (17 m, 9 m y 4 m) en el momento de la carga.
    static func initialKitchenOrders(now: Date = Date()) -> [KitchenOrder] {
        [
            KitchenOrder(
                id: "AT-398",
                table: "02",
                createdAt: now.addingTimeInterval(-17 * 60),
                status: .pending,
                notes: "CLIENTE CON ALERGIA SEVERA A LOS FRUTOS SECOS",
                items: [
                    KitchenItem(
                        name: "Solomillo de Vaca Madurada",
                        quantity: 2,
                        options: ["Al punto (Medium rare)", "Patatas baby asadas", "Salsa pimienta verde"],
                        kitchenNote: "Sin ningún tipo de fruto seco en emplatado"
                    ),
                    KitchenItem(
                        name: "Tartar de Salmón & Aguacate",
                        quantity: 1,
                        options: ["Ponzu y Lima"],
                        kitchenNote: ""
                    )
                ]
            ),
            KitchenOrder(
                id: "AT-401",
                table: "07",
                createdAt: now.addingTimeInterval(-9 * 60),
                status: .inProgress,
                notes: "",
                items: [
                    KitchenItem(
                        name: "Risotto de Boletus & Trufa Negra",
                        quantity: 1,
                        options: ["Tradicional mantecado", "Láminas de trufa negra fresca"],
                        kitchenNote: "Poco punto de sal"
                    ),
                    KitchenItem(
                        name: "Lubina Salvaje a la Espalda",
                        quantity: 1,
                        options: ["Punto jugoso (Recomendado)"],
                        kitchenNote: ""
                    )
                ]
            ),
            KitchenOrder(
                id: "AT-395",
                table: "11",
                createdAt: now.addingTimeInterval(-4 * 60),
                status: .ready,
                notes: "Mesa con carricoche de bebé",
                items: [
                    KitchenItem(
                        name: "Burrata de Puglia & Higos",
                        quantity: 1,
                        options: ["Focaccia artesanal de romero", "Láminas Jamón Ibérico"],
                        kitchenNote: ""
                    ),
                    KitchenItem(
                        name: "Vino Tinto Ribera del Duero",
                        quantity: 2,
                        options: [],
                        kitchenNote: ""
                    )
                ]
            )
        ]
    }

    // MARK: - Comandas de prueba (botón «+ Nueva Comanda»)

    private static let randomTables = ["01", "03", "05", "08", "12", "14"]

    private static let demoItemPool: [KitchenItem] = [
        KitchenItem(name: "Tartar de Salmón & Aguacate", quantity: 1, options: ["Ponzu y Lima"], kitchenNote: ""),
        KitchenItem(name: "Risotto de Boletus & Trufa", quantity: 2, options: ["Tradicional mantecado"], kitchenNote: "Mesa con prisa"),
        KitchenItem(name: "Solomillo de Vaca Madurada", quantity: 1, options: ["Poco hecho (Bleu)", "Patatas asadas"], kitchenNote: ""),
        KitchenItem(name: "Burrata de Puglia", quantity: 1, options: ["Focaccia romero"], kitchenNote: "")
    ]

    /// Genera una comanda aleatoria para demostrar la entrada en vivo del KDS.
    static func randomKitchenOrder(now: Date = Date()) -> KitchenOrder {
        let table = randomTables.randomElement() ?? "01"
        let code = "AT-\(Int.random(in: 405...494))"
        let item = demoItemPool.randomElement() ?? demoItemPool[0]

        return KitchenOrder(
            id: code,
            table: table,
            createdAt: now,
            status: .pending,
            notes: Bool.random() ? "" : "Mesa VIP con comensal intolerante a la lactosa",
            items: [item],
            subtotal: 28.50,
            tip: 0
        )
    }

    // MARK: - Dataset de demostración para el divisor de cuenta

    /// Se usa cuando no hay carrito ni comanda activa, para que el modal
    /// de dividir cuenta siga siendo interactivo, igual que en el prototipo.
    static let demoSplitDataset = SplitDataset(
        source: .demo,
        items: [
            SplitLine(id: "mock-1", name: "Burrata de Puglia & Higos", quantity: 1, totalPrice: 13.00),
            SplitLine(id: "mock-2", name: "Solomillo de Vaca Madurada", quantity: 1, totalPrice: 26.50),
            SplitLine(id: "mock-3", name: "Vino Tinto Ribera (2 copas)", quantity: 2, totalPrice: 9.60)
        ],
        subtotal: 49.10,
        tip: 4.90,
        grandTotal: 54.00
    )
}
