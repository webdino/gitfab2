# use this script like
# $bundle exec rails runner "eval(File.read 'script/add_kind_to_attachment.rb')"

def change doc, class_name, card
  xpath = "//a[@class='#{class_name}']"
  doc.xpath(xpath).each do |dom|
    if dom.attribute('id').present?
      id = dom.attribute('id').value
      attachment = card.attachments.where(markup_id: id).first
      if attachment.present?
        attachment.kind = class_name
        attachment.save!
      end
    end
  end
end

def convert card
  return if card.attachments.length == 0
  doc = Nokogiri::HTML.parse(card.description, nil, 'UTF-8')
  change doc, 'material', card
  change doc, 'tool', card
  change doc, 'blueprint', card
  change doc, 'attachment', card
  card.save!
end

Project.all.each do |project|
  project.states.each do |state|
    convert(state)
    state.annotations.each {|annotation| convert(annotation)}
  end
end
