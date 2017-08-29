import UIKit
import Kingfisher
import MarkdownView
import OctavKit
import Then

final class SessionViewController: UIViewController {
    @IBOutlet fileprivate weak var contentView: UIView!
    @IBOutlet fileprivate weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var startToEndLabel: UILabel!
    @IBOutlet fileprivate weak var tagCollectionView: UICollectionView!
    @IBOutlet fileprivate weak var avatarImageView: CircleImageView!
    @IBOutlet fileprivate weak var nicknameLabel: UILabel!
    @IBOutlet fileprivate weak var abstractMarkdownView: MarkdownView!
    @IBOutlet fileprivate weak var abstractMarkdownViewHeight: NSLayoutConstraint!

    fileprivate var session: Session!

    override func viewDidLoad() {
        super.viewDidLoad()
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        setupLayout(session: session)
    }
}

extension SessionViewController {
    static func instantiate(session: Session) -> SessionViewController {
        return Storyboard.session.instantiate(type: SessionViewController.self).then {
            $0.session = session
        }
    }
}

extension SessionViewController {
    fileprivate func setupLayout(session: Session) {
        setNoTitleBackButton()
        hideLayout()
        titleLabel.text = session.title
        startToEndLabel.text = session.startsOn.string(format: .custom("yyyy/MM/dd HH:mm"))
        avatarImageView.kf.setImage(with: session.speaker.avatarURL.secure)
        nicknameLabel.text = session.speaker.nickname
        abstractMarkdownView.load(markdown: session.abstract)
        abstractMarkdownView.isScrollEnabled = false
        abstractMarkdownView.onRendered = { [weak self] (height: CGFloat) in
            guard let strongSelf = self else { return }
            strongSelf.showLayout()
            strongSelf.abstractMarkdownViewHeight.constant = height
            strongSelf.view.setNeedsLayout()
        }
        abstractMarkdownView.onTouchLink = { [weak self] (request: URLRequest) -> Bool in
            guard let url = request.url, let scheme = url.scheme else { return false }
            switch scheme {
            case "file":
                return true
            case "http", "https":
                self?.presentSafariViewController(url: url, animated: true)
                return false
            default:
                return false
            }
        }
    }

    private func showLayout() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        contentView.isHidden = false
    }

    private func hideLayout() {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        contentView.isHidden = true
    }
}

// MARK: - UICollectionViewDataSource
extension SessionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return session.tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(with: TagCollectionViewCell.self, for: indexPath).then {
            $0.setup(name: session.tags[indexPath.row].rawValue)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SessionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return TagCollectionViewCell.cellSize(by: session.tags[indexPath.row].rawValue)
    }
}
