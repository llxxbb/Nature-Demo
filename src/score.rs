use crate::send_business_object;

#[test]
fn score_test() {
    let _id = send_business_object("score/table", &first_input()).unwrap();
}


fn first_input() -> Vec<KV> {
    let mut content: Vec<KV> = vec![];
    content.push(KV::new("class5/name1/subject1", 92));
    content.push(KV::new("class5/name1/subject2", 85));
    content.push(KV::new("class5/name1/subject3", 99));
    content.push(KV::new("class5/name2/subject1", 67));
    content.push(KV::new("class5/name2/subject2", 81));
    content.push(KV::new("class5/name2/subject3", 75));
    content.push(KV::new("class2/name1/subject1", 100));
    content.push(KV::new("class2/name1/subject2", 98));
    content.push(KV::new("class2/name1/subject3", 73));
    content
}

#[derive(Serialize)]
struct KV {
    pub key: String,
    pub value: i32,
}

impl KV {
    pub fn new(key: &str, value: i32) -> Self {
        KV {
            key: key.to_string(),
            value,
        }
    }
}
