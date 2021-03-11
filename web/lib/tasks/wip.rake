
task wip: :environment do
	require "google/cloud/vision"

	image_annotator = Google::Cloud::Vision.image_annotator
	image_path      = 'https://scontent-gig2-1.cdninstagram.com/v/t51.2885-15/e35/151784047_1919199544913266_5030728972930945945_n.jpg?tp=1&_nc_ht=scontent-gig2-1.cdninstagram.com&_nc_cat=110&_nc_ohc=WevJPpHQwEsAX9Hldt_&oh=be03bee8a9b0566c1ab909bb2759978c&oe=60460AC6'
	response        = image_annotator.text_detection(image:       image_path,
											         max_results: 1)

	response.responses[0].text_annotations[0].description
end
