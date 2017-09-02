import UIKit
import OctavKit

final class SponsorViewController: UIViewController {
    @IBOutlet fileprivate weak var collectionView: UICollectionView!

    fileprivate var sponsors: [Int: [Sponsor]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setNoTitleBackButton()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension SponsorViewController {
    static func instantiate(sponsors: [Int: [Sponsor]]) -> SponsorViewController {
        return Storyboard.sponsor.instantiate(type: SponsorViewController.self).then {
            $0.sponsors = sponsors
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SponsorViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Sponsor.Group.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionCount = sponsors[section]?.count else { return 0 }
        return sectionCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(with: SponsorCollectionViewCell.self, for: indexPath).then {
            $0.setup(sponsor: sponsors[indexPath.section]![indexPath.row])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SponsorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sponsor = sponsors[indexPath.section]![indexPath.row]
        presentSafariViewController(url: sponsor.linkURL, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SponsorCollectionViewCell.size(by: sponsors[indexPath.section]![indexPath.row])
    }
}
