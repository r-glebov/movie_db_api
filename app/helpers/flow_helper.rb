module FlowHelper
  def success?(result, context = self)
    if result.success?
      yield result
    else
      context.present_error!(result.type, result.message)
    end
  end
  
  def present_error!(type, message, context = self)
    context.render json: { error: message }, status: type
  end
end
