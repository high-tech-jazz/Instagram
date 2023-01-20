//
//  HomeViewController.swift
//  Instagram
//
//  Created by 伊藤敬 on 2023/01/13.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // Firestoreのリスナー
    var listner: ListenerRegistration?
    
    override func viewDidLoad() {
        print("HomeViewController.viewDidLoad")
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listnerを登録して投稿のデータ更新を監視する
            let postRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            listner = postRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする
                self.postArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listnerを削除して監視を停止する
        listner?.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostdata(postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action: #selector(handleLikeButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    // セル内のLikeボタンがタップされた時に呼ばれるメソッド
    @objc func handleLikeButton(_ sender:UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためにmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    // セル内のコメントボタンがタップされた時に呼ばれるメソッド
    @objc func handleCommentButton(_ sender:UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: commentボタンがタップされました")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "EnterComment") as! EnterCommentViewController
        nextVC.postData = postData
        present(nextVC, animated: true)
    }
}
