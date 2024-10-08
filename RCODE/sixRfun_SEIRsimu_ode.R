SEIRsimuR <- function(pars, init_settings, num_periods = 2,t=0) {
  set.seed(22)
  tmp_ret=init_settings$var_trans_fun(pars)
  b_vec=tmp_ret[[1]]
  r_vec=tmp_ret[[2]]
  rh_vec=tmp_ret[[3]]
  bs_vec=tmp_ret[[4]]
  bl_vec=tmp_ret[[5]]
  stage_intervals=init_settings$stage_intervals
  n_stage=length(stage_intervals)
  ##
  init_settings$Di<-18
  init_settings$Dp<-0.8*init_settings$Dp
  init_settings$De<-0.8*init_settings$De
  init_settings$alpha<-1
  Di <- init_settings$Di
  Dp <- init_settings$Dp
  De <- init_settings$De
  Dq_vec <- init_settings$Dq
  Dqs_vec <- init_settings$Dqs
  alpha <- init_settings$alpha
  Dh <- init_settings$Dh
  MS<-init_settings$MS
  ML<-init_settings$ML
  N <- init_settings$N
  flowN_vec <- init_settings$flowN
  init_states <- init_settings$init_states
  days_to_fit <- init_settings$days_to_fit
  
  update_func <- function(stage_pars, states_old) {
    b <- stage_pars[1]
    r <- stage_pars[2]
    rh <- stage_pars[3]
    Dq <- stage_pars[4]
    Dqs <- stage_pars[5]
    n <- stage_pars[6]     
    bs<-stage_pars[7]
    bl<-stage_pars[8]
    
    
    S <- states_old[1]
    E <- states_old[2]
    P <- states_old[3]
    I <- states_old[4]
    A <- states_old[5]
    AA<-states_old[6]
    H <- states_old[7]
    R <- states_old[8]
    
    SS <- states_old[9]
    ST<-states_old[10]
    ES <- states_old[11]
    PS <- states_old[12]
    IS <- states_old[13]
    AS <- states_old[14]
    AAS <- states_old[15]
    HS <- states_old[16]
    RS <- states_old[17]
    
    
    SL <- states_old[18]
    LT <- states_old[19]
    EL <- states_old[20]
    PL <- states_old[21]
    IL <- states_old[22]
    AL <- states_old[23]
    AAL <- states_old[24]
    HL <- states_old[25]
    RL <- states_old[26]
    
    
    
    pS_vec <- c(b * (alpha * (P+PS+PL) +alpha * (A+AS+AL)+alpha * (AA+AAS+AAL)) / N, b * (I+IS+IL) / N, n /N, 1 - b *(alpha * (P+PS+PL) +alpha *(A+AS+AL)+alpha * (AA+AAS+AAL)+ (I+IS+IL)) /N - n / N)
    sample_S <- pS_vec*S

    pE_vec <- c(1 / De, n / N, 1 - 1 / De - n / N)
    sample_E <- pE_vec*E
 
    pP_vec <- c(r / Dp, (1 - r) / Dp, n/N, 1 - 1 / Dp - n/N)
    sample_P <- pP_vec*P
   
    pI_vec <- c(1 / Dq, 1 / Di, 1 - 1 / Dq - 1 / Di)
    sample_I<- pI_vec*I

    pA_vec <- c(1 / Di, n /N, 1 - 1 / Di - n /N)
    #sample_A <- rmultinom(1, size = A, prob = pA_vec)
    sample_A <-pA_vec*A
    pAA_vec <- c(0)
    sample_AA <-pA_vec*AA
    
    pH_vec <- c(1 / Dh, 1 - 1 / Dh)
    sample_H <- pH_vec*H

    pR_vec <- c(n /N, 1 - n /N)
    sample_R <- pR_vec*R

    pSS_vec <- c(b * (alpha * (P+PS+PL) +alpha * (A+AS+AL) +alpha * (AA+AAS+AAL)) / N, b *(I+IS+IL) /N,(MS-1)*b * (alpha * (P+PS+PL) +alpha * (A+AS+AL) +alpha * (AA+AAS+AAL)) / N,(MS-1)*b *(I+IS+IL) /N, n /N, 1 - MS*b * (alpha * (P+PS+PL) +alpha * (A+AS+AL) +alpha * (AA+AAS+AAL)) / N-MS*b *(I+IS+IL) /N- n / N)  
    sample_SS <-SS*pSS_vec
    
    pST_vec <- c(bs *(alpha * PS +alpha * AS+alpha * AAS)/(ST+ES+PS+AS+AAS+IS+0.000001),bs*IS/(ST+ES+PS+AS+AAS+IS+0.000001), n /N, 1 - bs* (alpha * PS +alpha * AS+alpha * AAS+ IS ) /(ST+ES+PS+AS+AAS+IS+0.000001) - n / N)  #(SL+EL+PL+ALe+ALl+ILe+ILl)
    
    sample_ST <-ST*pST_vec
 
    pES_vec <-  c(1 / De, n / N, 1 - 1 / De - n / N)
   
    sample_ES<-ES*pES_vec
 
    pPS_vec <- c(r / Dp, (1 - rh) / Dp,(rh-r)/Dp, n/N, 1 - 1 / Dp - n/N)
    sample_PS <-pPS_vec *PS

    pIS_vec <- c(1 / Dqs, 1 / Di, 1 - 1 / Dqs - 1 / Di )
    sample_IS <-pIS_vec*IS

    pAS_vec <- c(1 / Di, n /N, 1 - 1 / Di - n /N )
    sample_AS<-pAS_vec*AS

    pAAS_vec <- c(1 / Dqs, 1 / Di, 1 - 1 / Dqs - 1 / Di)
    sample_AAS <-pAAS_vec*AAS
 
    pHS_vec <- c(1 / Dh, 1 - 1 / Dh)
    sample_HS <-pHS_vec*HS

    pRS_vec <- c(n /N, 1 - n /N)
    sample_RS <-pRS_vec*RS
 
    pSL_vec <- c(b * (alpha * (P+PS+PL) +alpha * (A+AS+AL) +alpha * (AA+AAS+AAL)) / N, b *(I+IS+IL) /N,(ML-1)*b * (alpha * (P+PS+PL) +alpha * (A+AS+AL) +alpha * (AA+AAS+AAL)) / N,(ML-1)*b *(I+IS+IL) /N, n /N, 1 - ML*b * (alpha * (P+PS+PL) +alpha * (A+AS+AL) +alpha * (AA+AAS+AAL)) / N-ML*b *(I+IS+IL) /N- n / N)  #(SL+EL+PL+ALe+ALl+ILe+ILl)
 
    sample_SL <-SL*pSL_vec
    
    pLT_vec <- c(bl * (alpha * PL +alpha * AL+alpha * AAL)/(LT+EL+PL+AL+AAL+IL+0.000001),bl*IL/(LT+EL+PL+AL+AAL+IL+0.000001), n /N, 1 - bl* (alpha * PL +alpha * AL+alpha * AAL+ IL ) /(LT+EL+PL+AL+AAL+IL+0.000001) - n / N)  #(SL+EL+PL+ALe+ALl+ILe+ILl)
 
    sample_LT <-LT*pLT_vec
 
    pEL_vec <-  c(1 / De, n / N, 1 - 1 / De - n / N)
   
    sample_EL<-EL*pEL_vec
  
    pPL_vec <- c(r / Dp, (1 - rh) / Dp,(rh-r)/Dp, n/N, 1 - 1 / Dp - n/N)
    sample_PL <-pPL_vec *PL
   
    pIL_vec <- c(1 / Dqs, 1 / Di, 1 - 1 / Dqs - 1 / Di )
    sample_IL <-pIL_vec*IL
 
    pAL_vec <- c(1 / Di, n /N, 1 - 1 / Di - n /N )
    sample_AL<-pAL_vec*AL

    pAAL_vec <- c(1 / Dqs, 1 / Di, 1 - 1 / Dqs - 1 / Di)
    sample_AAL <-pAAL_vec*AAL

    pHL_vec <- c(1 / Dh, 1 - 1 / Dh)
    sample_HL <-pHL_vec*HL

    pRL_vec <- c(n /N, 1 - n /N)
    sample_RL <-pRL_vec *RL
    
 
    S_new <- sample_S[4] + 0.06*n
    E_new <- sample_E[3] + sample_S[1] +sample_S[2]
    P_new <- sample_P[4] + sample_E[1]
    I_new <- sample_I[3] + sample_P[1]
    A_new <- sample_A[3] + sample_P[2]
    AA_new <- sample_AA[1]
    H_new <- sample_H[2] + sample_I[1]
    R_new <- sample_R[2] + sample_I[2] + sample_A[1] + sample_H[1]
    Onset_expect <- sample_P[1]
    expect_H<-sample_I[1]
    expect_A<-sample_P[2]
    expect_Ea<-sample_S[1]
    expect_Ei<-sample_S[2]
    
    SL_new <- sample_SL[6] + 0.48*n
    LT_new <- (sample_SL[3]+sample_SL[4])+sample_LT[4]
    
    EL_new <- sample_EL[3] + sample_LT[1] +sample_LT[2]+ (sample_SL[1] +sample_SL[2])
    PL_new <- sample_PL[5] + sample_EL[1]
    
    IL_new <- sample_IL[3] + sample_PL[1]
    AL_new <- sample_AL[3] + sample_PL[2]
    
    AAL_new <- sample_AAL[3] + sample_PL[3]
    
    
    HL_new <- sample_HL[2] + sample_IL[1] + sample_AAL[1]
    RL_new <- sample_RL[2] + sample_IL[2] + sample_AL[1]+ sample_AAL[2] + sample_HL[1]
    
    
    LOnset_expect <- sample_PL[1]+ sample_PL[3]
    
    expect_HL<-sample_IL[1]+sample_AAL[1]
    expect_AL<-sample_PL[2]
    
    expect_ELaP<-sample_SL[1]
    expect_ELiP<-sample_SL[2]
    expect_ELaH<-sample_LT[1]
    expect_ELiH<-sample_LT[2]
    
    
    
    SS_new <- sample_SS[6] + 0.48*n
    ST_new <- (sample_SS[3]+sample_SS[4])+sample_ST[4]
    
    ES_new <- sample_ES[3] + sample_ST[1] +sample_ST[2]+ (sample_SS[1] +sample_SS[2])
    PS_new <- sample_PS[5] + sample_ES[1]
    
    IS_new <- sample_IS[3] + sample_PS[1]
    AS_new <- sample_AS[3] + sample_PS[2]
    
    AAS_new <- sample_AAS[3] + sample_PS[3]
    
    
    HS_new <- sample_HS[2] + sample_IS[1] + sample_AAS[1]
    RS_new <- sample_RS[2] + sample_IS[2] + sample_AS[1]+ sample_AAS[2] + sample_HS[1]
    
    
    SOnset_expect <- sample_PS[1]+ sample_PS[3]
    
    expect_HS<-sample_IS[1]+sample_AAS[1]
    expect_AS<-sample_PS[2]
    
    expect_ESaP<-sample_SS[1]
    expect_ESiP<-sample_SS[2]
    expect_ESaH<-sample_ST[1]
    expect_ESiH<-sample_ST[2]
    
    ps<-(sample_ST[1] +sample_ST[2]+ (sample_SS[1] +sample_SS[2]))/(sample_S[1] +sample_S[2]+sample_ST[1] +sample_ST[2]+ (sample_SS[1] +sample_SS[2])+ sample_LT[1] +sample_LT[2]+ (sample_SL[1] +sample_SL[2])+0.0000001)
   
    ps1<-(sample_S[1] +sample_S[2]+sample_ST[1] +sample_ST[2]+ (sample_SS[1] +sample_SS[2])+ sample_LT[1] +sample_LT[2]+ (sample_SL[1] +sample_SL[2]))
    pl<-(sample_LT[1] +sample_LT[2]+ (sample_SL[1] +sample_SL[2]))/(sample_S[1] +sample_S[2]+sample_ST[1] +sample_ST[2]+ (sample_SS[1] +sample_SS[2])+ sample_LT[1] +sample_LT[2]+ (sample_SL[1] +sample_SL[2])+0.0000001)
    
    saf<-bs *ST_new*alpha /(ST_new+ES_new+PS_new+AS_new+AAS_new+IS_new+0.000001)
    ssf<-bs *ST_new/(ST_new+ES_new+PS_new+AS_new+AAS_new+IS_new+0.000001)
    laf<-bl *LT_new*alpha /(LT_new+EL_new+PL_new+AL_new+AAL_new+IL_new+0.000001)
    lsf<-bl *LT_new/(LT_new+EL_new+PL_new+AL_new+AAL_new+IL_new+0.000001)
    
    N1s<-saf*Dp+ssf*((1/Di+1/Dq)^(-1))
    N1as<-saf*Dp+saf*((1/Di+1/Dq)^(-1))
    N1a<-saf*(Dp+Di)
    Rhs<-ps*(r*N1s+(rh-r)*N1as+(1-rh)*N1a)
    
    N2s<-laf*Dp+lsf*((1/Di+1/Dq)^(-1))
    N2as<-laf*Dp+laf*((1/Di+1/Dq)^(-1))
    N2a<-laf*(Dp+Di)
    Rhl<-pl*(r*N2s+(rh-r)*N2as+(1-rh)*N2a)
    Rh<- Rhs+Rhl
    Rc<-(ps+pl)*( r*b*(Dp*alpha+(1/Di+1/Dq)^(-1)) + (rh-r)*alpha*b*(Dp+(1/Di+1/Dq)^(-1)) + (1-rh)*alpha*b*(Dp+Di) ) +  (1-ps-pl)*(  r*b*(Dp*alpha+(1/Di+1/Dq)^(-1)) +(1-r)*alpha*b*(Dp+Di)  ) 
    RZ<-Rh+Rc
    
    
    Add<-sample_PS[3]+sample_PL[3]
    
    STC<-sample_ST[1]+sample_ST[2]
    STJ<-(sample_SS[3]+sample_SS[4])
    
    BL<-ST/(ST+ES+PS+AS+AAS+IS)
    LTC<-sample_LT[1]+sample_LT[2]
    LTJ<-(sample_SL[3]+sample_SL[4])
    
    ATCJ<-STJ+LTJ
    
    
    return(c(S_new, E_new, P_new, I_new, A_new, AA_new, H_new, R_new,SS_new,ST_new , ES_new, PS_new, IS_new, AS_new,AAS_new, HS_new, RS_new,SL_new,LT_new, EL_new,PL_new, IL_new, AL_new,AAL_new, HL_new, RL_new, Onset_expect,expect_H,expect_A,expect_Ea,expect_Ei,SOnset_expect,expect_HS,expect_AS,expect_ESaP,expect_ESiP,expect_ESaH,expect_ESiH, LOnset_expect,expect_HL,expect_AL,expect_ELaP, expect_ELiP,expect_ELaH,expect_ELiH,ps,ps1,pl,saf,ssf,laf,lsf,Add,STC,STJ,BL,LTC,LTJ,Rhs,Rhl,Rh,Rc,RZ,ATCJ,b,r,rh))
  }
 
  states_mat <- matrix(0, length(days_to_fit), length(init_states) + 42)
  
  states_mat[, 1] <- days_to_fit
  
  colnames(states_mat) <- c("time","S", "E", "P", "I", "A","AA", "H", "R", "SS","ST", "ES", "PS", "IS", "AS","AAS", "HS", "RS","SL","LT", "EL", "PL", "IL", "AL","AAL", "HL", "RL", "Onset_expect","expect_H","expect_A","expect_Ea","expect_Ei", "SOnset_expect","expect_HS","expect_AS", "expect_ESaP","expect_ESiP","expect_ESaH","expect_ESiH","LOnset_expect","expect_HL","expect_AL","expect_ELaP", "expect_ELiP","expect_ELaH","expect_ELiH","ps","ps1","pl","saf","ssf","laf","lsf","Add","STC","STJ","BL","LTC","LTJ","Rhs","Rhl","Rh","Rc","RZ","ATCJ","b","r","rh")
  
  stage_start <- c(1,15)            
  stage_end <- c(14,length(days_to_fit))
  
  myold_states <- init_states
  for (i_stage in 1:2) {
    
    for (d in stage_start[i_stage]:stage_end[i_stage]) {
      dd<-d
      if(dd >= t) { 
        dd <- t
      }
      i<-1
      if(dd >= 15) {  
        i <- 2
      }
      
      
      
      stage_pars_setings <- c(b =2*b_vec[i], r = r_vec[1], rh= rh_vec[i],Dq = Dq_vec[dd%/%5.00001+1],Dqs = Dqs_vec[dd%/%5.00001+1], n = flowN_vec[i],bs=2*bs_vec[i],bl=2*bl_vec[i])
      states_mat[d, -1] <- update_func(stage_pars = stage_pars_setings, states_old = myold_states)
     
      myold_states <- states_mat[d, -1]
      
    }
  }
  if(num_periods == 2) {  
    states_mat <- states_mat
  }
  
  else if (num_periods %in% c(1)) {  
    i_stage <- num_periods
    
    for (d in stage_start[i_stage]:length(days_to_fit)) {
      stage_pars_setings <- c(b = b_vec[i_stage], r = r_vec[1],uh = uh_vec[1],Dq = Dq_vec[d%/%5.00001+1], n = flowN_vec[i_stage],bs=bs_vec[1],bl=bl_vec[1])
      myold_states <- states_mat[d - 1, -1]
      states_mat[d, -1] <- update_func(stage_pars = stage_pars_setings, states_old = myold_states)
    }
  }
  else {
    print("num_periods has to be 1，2!")
    q(save="no")
  }
  
  return(states_mat)
}
