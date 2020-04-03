# frozen_string_literal: true

# Serializer to strip away the cruft in the foodbanks table
class FoodbankSerializer < ActiveModel::Serializer
  attributes :address, :city, :state, :zip
  # TODO: attribute  :phone_public_help, key: :phone
  attribute :fb_name, key: :name
  attribute :fb_nickname, key: :nickname
  attributes :display_url, :fb_agency_locator_url, :fb_url, :fb_fano_url

  def address
    return object.address1 if object.address2.nil?

    "#{object.address1} #{object.address2}"
  end

  def display_url
    return '' if  !object.fb_agency_locator_url &&
                  !object.fb_url &&
                  !object.fb_fano_url?

    chosen_url
  end

  def chosen_url
    return object.fb_agency_locator_url if object.fb_agency_locator_url?
    return object.fb_url if object.fb_url?

    object.fb_fano_url
  end
end
