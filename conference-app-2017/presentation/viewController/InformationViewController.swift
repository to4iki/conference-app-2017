import UIKit
import AVFoundation
import Kingfisher
import OctavKit
import Result
import Then
import QRCodeReader

final class InformationViewController: UITableViewController {
    fileprivate var sponsors: [Sponsor] = []

    lazy var readerViewController: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
            $0.showTorchButton = true
        }
        return QRCodeReaderViewController(builder: builder).then {
            $0.delegate = self
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSponsor()
    }
}

extension InformationViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == "\(SponsorViewController.className)Segue" {
            let viewController = segue.destination as! SponsorViewController
            viewController.sponsors = sponsors.groping()
        }
    }
}

extension InformationViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            presentQRCodeReader(animated: true, completion: nil)
        case (2, 0):
            presentClearCacheDialog(animated: true, completion: nil)
        default:
            break
        }
    }
}

extension InformationViewController {
    fileprivate func setupSponsor() {
        SponsorService.shared.read { [weak self] result in
            if case .success(let value) = result {
                self?.sponsors = value
            }
        }
    }

    fileprivate func presentClearCacheDialog(animated: Bool, completion: (() -> Void)?) {
        let alert = UIAlertController(title: nil, message: "Clear App's Cache", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "Clear", style: .default) { [weak self] _ in
            self?.clearCache { result in
                if case .success(_) = result {
                    let dialog = UIAlertController(title: nil, message: "Deleted all data from the cache", preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    self?.present(dialog, animated: true, completion: nil)
                }
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(clearAction)
        present(alert, animated: animated, completion: completion)
    }

    private func clearCache(completion: @escaping (Result<Void, DiskCacheError>) -> Void) {
        ImageCache.default.clearDiskCache()
        DiskCache.shared.removeAll(completion: completion)
    }
}
