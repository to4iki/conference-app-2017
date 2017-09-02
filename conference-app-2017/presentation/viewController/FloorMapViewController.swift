import UIKit

final class FloorMapViewController: UIViewController {
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setNoTitleBackButton()
        scrollView.delegate = self
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: .didScrollViewDoubleTap)
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        resetScrollView()
    }
}

extension FloorMapViewController {
    static func instantiate() -> FloorMapViewController {
        return Storyboard.floorMap.instantiate(type: FloorMapViewController.self)
    }
}

extension FloorMapViewController {
    func didScrollViewDoubleTap(gesture: UITapGestureRecognizer) {
        guard gesture.state == UIGestureRecognizerState.ended else { return }
        if scrollView.zoomScale < scrollView.maximumZoomScale {
            let zoomedRect = zoomRectForScale(scrollView.maximumZoomScale, center: gesture.location(in: gesture.view))
            scrollView.zoom(to: zoomedRect, animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }

    fileprivate func resetScrollView() {
        scrollView.setZoomScale(1.0, animated: true)
        scrollView.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
    }

    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        let size = CGSize(width: scrollView.frame.size.width / scale, height: scrollView.frame.size.height / scale)
        let origin = CGPoint(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0)
        return CGRect(origin: origin, size: size)
    }
}

// MARK: - UIScrollViewDelegate
extension FloorMapViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: - Selector
private extension Selector {
    static let didScrollViewDoubleTap = #selector(FloorMapViewController.didScrollViewDoubleTap)
}
