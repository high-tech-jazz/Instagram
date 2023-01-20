//
//  EnterCommentViewController.swift
//  Instagram
//
//  Created by 伊藤敬 on 2023/01/19.
//

import UIKit
import Firebase

class EnterCommentViewController: UIViewController {
    var postData: PostData!
    @IBOutlet weak var commentForm: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
print("EnterCommentViewController")
    }
    
    @IBAction func postComment(_ sender: Any) {
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            
            let dt = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            let dateString = dateFormatter.string(from: dt)
            
            let user = Auth.auth().currentUser
            var dispName:String = ""
            if let user = user {
                dispName = user.displayName!
            }
            
            // commentsに更新データを書き込む
            let commentRef = Firestore.firestore().collection(Const.CommentPath).document()
            let commentDic = [
                "pid": postData.id,
                "date": dateString,
                "name": dispName,
                "comment": self.commentForm.text!
            ] as [String : Any]
            commentRef.setData(commentDic)
            
            // postsに更新データを書き込む
            var newComment = String(myid) + "_" + dateString + "_" + dispName + "_" + String(self.commentForm.text!)
            updateValue = FieldValue.arrayUnion([newComment])
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["comments": updateValue])
            
            dismiss(animated: true)
        }
    }
    
    
    @IBAction func cancelPost(_ sender: Any) {
        dismiss(animated: true)
    }
}
