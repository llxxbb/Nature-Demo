use nature_common::Instance;

use crate::{loop_get_by_key, send_instance};

#[test]
fn test() {
    #[derive(Serialize)]
    struct Delivery;

    let mut ins = Instance::new("delivery").unwrap();
    ins.para = "/A/B".to_string();
    let id = send_instance(&ins).unwrap();

    finish_delivery(id, "/A/B");
    finish_delivery(id, "/B/C");
    finish_delivery(id, "/C/D");
}

fn finish_delivery(id: u128, para: &str) {
    let _last = loop_get_by_key(id, "deliveryState", para, 1);
    let mut ins = Instance::new("deliveryState").unwrap();
    ins.para = para.to_string();
    ins.states.insert("finished".to_owned());
    ins.state_version = 2;
    let _id = send_instance(&ins).unwrap();
}
