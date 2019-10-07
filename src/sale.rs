use nature_demo_common::{Commodity, Order, SelectedCommodity};

use crate::{get_instance_by_id, send_instance};

pub fn send_order_to_nature() -> u128 {
    // create an order
    let order = create_order_object();
    let id = send_instance("/sale/order", &order).unwrap();
    dbg!(id);

    // send again
    let msg = send_instance("/sale/order", &order).err().unwrap().to_string();
    assert_eq!(msg.contains("DaoDuplicated"), true);

    // check created instance for order
    let rtn = get_instance_by_id(id, "/B/sale/order:1").unwrap();
    assert_eq!(rtn.id, id);

    // check created instance for order state
    let rtn = get_instance_by_id(id, "/B/sale/orderState:1").unwrap();
    assert_eq!(rtn.id, id);
    assert_eq!(rtn.states.contains("new"), true);
    let from = rtn.from.as_ref().unwrap();
    assert_eq!(from.meta, "/B/sale/order:1");
    id
}

fn create_order_object() -> Order {
    Order {
        user_id: 123,
        price: 100,
        items: vec![
            SelectedCommodity {
                item: Commodity { id: 1, name: "phone".to_string() },
                num: 1,
            },
            SelectedCommodity {
                item: Commodity { id: 2, name: "battery".to_string() },
                num: 2,
            }
        ],
        address: "a.b.c".to_string(),
    }
}
