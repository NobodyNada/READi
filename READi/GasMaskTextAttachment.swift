//
//  GasMaskTextAttachment.swift
//  READi
//
//  Created by NobodyNada on 3/26/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit

class GasMaskTextAttachment: NSTextAttachment {
	func getGasMaskImage() -> UIImage {
		return UIImage(named: "gas_mask.png")!
	}
	
	var actualImage: UIImage?
	var width: CGFloat? {
		didSet {
			resizeImage()
		}
	}
	
	override var image: UIImage? {
		didSet {
			resizeImage()
		}
	}
	
	var imageURL: URL? {
		didSet {
			self.image = getGasMaskImage()
			guard let url = imageURL else { return }
			DispatchQueue.global().async {
				self.actualImage = (try? Data(contentsOf: url)).map { UIImage(data: $0) } ?? nil
			}
		}
	}
	
	func tapped() {
		if actualImage != nil {
			if image == actualImage {
				image = getGasMaskImage()
			} else {
				image = actualImage
			}
		}
	}
	
	
	private func resizeImage() {
		guard let image = image, let width = width else { return }
		
		let aspectRatio = image.size.width/image.size.height
		bounds.size = CGSize(width: width, height: width / aspectRatio)
	}
}
