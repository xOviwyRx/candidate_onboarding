module CandidateProfilesHelper
  BADGE_CLASSES = {
    FieldProvenance::EXTRACTED => "bg-green-100 text-green-700",
    FieldProvenance::CHECK => "bg-amber-100 text-amber-800",
    FieldProvenance::MISSING => "bg-gray-100 text-gray-600"
  }.freeze

  def provenance_badge(field)
    label = @provenance.label_for(field)
    return if label.nil?

    tag.span(label, class: "ml-2 rounded px-1.5 py-0.5 text-xs font-medium #{BADGE_CLASSES[label]}")
  end
end
