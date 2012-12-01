#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  module Records

    #
    # Public: An iCloud user's info. This is returned at login, and isn't (as far
    # as I'm aware) editable.
    #
    class DsInfo
      include Record
      has_fields(
        :primary_email_verified,
        :last_name,
        :icloud_apple_id_alias,
        :apple_id_alias,
        :apple_id,
        :has_icloud_qualifying_device,
        :dsid,
        :primary_email,
        :status_code,
        :full_name,
        :locked,
        :first_name,
        :apple_id_aliases
      )

      def to_s
        full_name
      end
    end
  end
end
