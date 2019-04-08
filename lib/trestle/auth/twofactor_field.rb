module Trestle
  module Auth
    class TwofactorField < Trestle::Form::Field
      attr_accessor :current_user
      
      def initialize(builder, template, name, options={}, &block)
        @current_user = options[:current_user]
        super(builder, template, name, options, &block)
      end
      
      def field
        qr = RQRCode::QRCode.new(@current_user.provisioning_uri(Trestle.config.auth.twofactor_name), :size => 8, :level => :h )
        if @current_user.otp_verified
          #already verified, only show button to remove 2 factor auth
          template.link_to('Remove 2FA', "/admin/remove_twofactorauth", method: :post, class: "btn btn-danger", data: {toggle: "confirm", placement: "bottom"})
        else
          return content_tag :div, class: 'qr-group' do
            template.render(partial: "trestle/auth/qr_code", locals: {qr: qr, current_user: @current_user})
          end
        end
      end
    end
  end
end

Trestle::Form::Builder.register(:twofactor, Trestle::Auth::TwofactorField)