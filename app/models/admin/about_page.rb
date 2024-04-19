ActiveAdmin.register AboutPage do
  permit_params :title, :content

  form do |f|
    f.inputs 'About Page Details' do
      f.input :title, input_html: { disabled: true }  # Prevent changing the title
      f.input :content, as: :text
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :content
    end
  end
end