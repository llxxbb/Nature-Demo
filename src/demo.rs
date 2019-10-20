use nature_common::ParaForQueryByID;

use crate::{CLIENT, send_order_to_nature, send_payment_to_nature, URL_GET_BY_ID};

#[test]
fn demo_all_test() {
    let id = send_order_to_nature();
    send_payment_to_nature(id);
}

#[test]
fn temp_test() {
    let response = CLIENT.post(URL_GET_BY_ID).json(&ParaForQueryByID { id: 271448073389351988786345053349058430028, meta: "/B/sale/orderState:1".to_string() }).send();
    let msg = response.unwrap().text().unwrap();
    assert_eq!(msg.contains("271448073389351988786345053349058430028"), true);
}