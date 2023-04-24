//
//  ViewController.swift
//  M17_Concurrency
//
//  Created by Maxim NIkolaev on 08.12.2021.
//

import SnapKit

class ViewController: UIViewController {
    
    let service = Service()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 220, y: 220, width: 140, height: 140))
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    var imageStore: [UIImage?] = []
    
    let group = DispatchGroup()
    
    let semaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
                
        for i in 0...4 {
            onLoad(counter: i)
            // синхронно ожидаем выполнения предыдущего задания (для учебных целей)
//            group.wait()
        }
        
        group.notify(queue: .main) {
            print("All tasks done, building UI...")
            self.activityIndicator.stopAnimating()
            self.imageStore.forEach { image in
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
                self.stackView.addArrangedSubview(imageView)
            }
            print("These dogs are so cute, aren't they? :)")
        }
        
    }

    private func onLoad(counter: Int) {
        // Индикатор входа блока в группу
        group.enter()
        print("Run task - \(counter)")
        service.getImageURL { urlString, error in
            guard let urlString = urlString else { return }
            let image = self.service.loadImage(urlString: urlString)
            self.imageStore.append(image)
            
            // Когда запрос выполниться, делаем выход блока из группы
            self.group.leave()
            print("Done task - \(counter)")
        }
    }
    
    private func setupViews() {
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview()
        }
        
        stackView.addArrangedSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}

