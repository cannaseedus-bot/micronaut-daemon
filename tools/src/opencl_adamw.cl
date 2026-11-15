// Float32 AdamW update for the compact CPU-forward Gemma trainer.
// Bias correction and decoupled weight decay match torch.optim.AdamW defaults.
__kernel void adamw_update(__global float* parameters,
                           __global const float* gradients,
                           __global float* first_moment,
                           __global float* second_moment,
                           const uint count,
                           const float learning_rate,
                           const float beta1,
                           const float beta2,
                           const float epsilon,
                           const float weight_decay,
                           const float correction1,
                           const float correction2) {
    const uint i=get_global_id(0);
    if(i>=count)return;
    const float g=gradients[i];
    const float m=beta1*first_moment[i]+(1.0f-beta1)*g;
    const float v=beta2*second_moment[i]+(1.0f-beta2)*g*g;
    first_moment[i]=m;
    second_moment[i]=v;
    const float m_hat=m/correction1;
    const float v_hat=v/correction2;
    const float p=parameters[i];
    parameters[i]=p-learning_rate*(m_hat/(sqrt(v_hat)+epsilon)+weight_decay*p);
}
