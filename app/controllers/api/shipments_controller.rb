module Api
  class ShipmentsController < ApplicationController
    before_filter :authenticate_user!

    def create
      @ext = Shipment.where({to: shipment_params['to'], from: shipment_params['from'], date: shipment_params['date'], user: current_user}).first
      @order = Order.where(id: params['order_id']).first

      if @ext
        puts 'Exist!!!!!!!!!!!!!!!!!!'
        @shipment = @ext
        if params[:order_id]
          puts params[:order_id] + '***************************************'
          @shipment.order.push(@order) if @order
          puts 'Order #################################'
          puts @shipment.order
          puts 'Order #################################'
          if @shipment.save
            if @order.has_attribute?(:shipment)
               @order.shipment.push(@shipment)
            else
              @order[:shipment] = [@shipment]
            end
            render json: @shipment, status: :accepted
          else
            render json: { messsage: 'Bad request' }, status: 400
          end
        end
      else
        @shipment = Shipment.new(shipment_params)
        @shipment.user = current_user
        if params[:order_id]
          puts params[:order_id] + '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
          @shipment.order = [@order] if @order
          puts 'Order ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
          puts @shipment.order
          if @shipment.save
            if @order.shipments
              @order.shipments.push(@shipment)
              puts 'Shipment ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
            else
              @order[:shipment] = [@shipment]
              puts 'Shipment ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
            end
            @order.save!
            render json: @shipment, status: :accepted
          else
            render json: { messsage: 'Bad request' }, status: 400
          end
        end
      else
        if @shipment.save
            render json: @shipment, status: :accepted
          else
            render json: { messsage: 'Bad request' }, status: 400
          end
      end
    end

    def list
      @shipments = current_user.shipments
      render 'index'
    end

    def update
      @shipment = Shipment.where(id: params[:shipment_id]).first

      if @shipment && @shipment.update(shipment_params)
        # @shipment.order.save
        render json: @shipment, status: :accepted
      else
        render json: { messsage: 'No orders found' }, status: 404
      end
    end

    private

    def shipment_params
      params.require(:shipment).permit(:to, :date, :from, :status)
    end
  end
end
