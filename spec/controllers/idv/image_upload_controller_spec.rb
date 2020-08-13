require 'rails_helper'

describe Idv::ImageUploadController do
  describe '#create' do
    # let(:upload_errors) { [] }
    # response_mock = instance_double(Acuant::Responses::ResponseWithPii,
    #                                 success?: upload_errors.empty?,
    #                                 errors: upload_errors,
    #                                 to_h: {
    #                                   success: upload_errors.empty?,
    #                                   errors: upload_errors,
    #                                 },
    #                                 pii_from_doc: {})
    # client_mock = instance_double(Acuant::AcuantClient, post_images: response_mock)

    let(:image_data) { 'data:image/png;base64,AAA' }

    before do
      sign_in_as_user
      # allow(subject).to receive(:doc_auth_client).and_return(doc_auth_client)
      # subject.user_session['idv/doc_auth'] = {} unless subject.user_session['idv/doc_auth']
    end

    it 'returns error status when not provided image fields' do
      post :create, params: {
        some_other_field: image_data,
        back_image: image_data,
      }, format: :json

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:success]).to eq(false)
      expect(json[:errors]).to eq('Missing image keys')
    end

    context 'when image upload succeeds' do
      it 'returns a successful response and modifies the session' do
        post :create, params: {
          front_image: image_data,
          back_image: image_data,
          selfie_image: image_data,
        }, format: :json

        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:success]).to eq(true)
        expect(json[:message]).to eq('Uploaded images')
        expect(subject.user_session['idv/doc_auth']).to include('api_upload')
      end
    end

    context 'when image upload fails' do
      before do
        DocAuthMockClient.mock_response!(
          method: :post_images,
          response: Acuant::Responses::ResponseWithPii.new(
          )
        )
      end

      let(:upload_errors) { ['Too blurry', 'Wrong document'] }

      it 'returns an error response and does not modify the session' do
        post :create, params: {
          front_image: image_data,
          back_image: image_data,
          selfie_image: image_data,
        }, format: :json

        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:success]).to eq(false)
        expect(json[:errors]).to eq('Too blurry')
        expect(subject.user_session['idv/doc_auth']).not_to include('api_upload')
      end
    end
  end
end
