////////////////////////////////////////////////////////////////////////////////////////////////
//
//  LocalShadow_Header.fxh : LocalShadow(���f���g�ݍ��ݔ�)
//  �V���h�E�}�b�v�쐬�ɕK�v�Ȋ�{�p�����[�^��`�̃w�b�_�t�@�C���ł��B
//  �����̃p�����[�^���V�F�[�_�G�t�F�N�g�t�@�C���� #include ���Ďg�p���܂��B
//
//  �쐬: �j��P
//
//  �{�G�t�F�N�g�Ή��ݒ���������f���ɑ΂��A�e���f���ɉ������p�����[�^�œK���������ōs���܂��B
//  �����̃t�@�C�����X�V���Ă�MME�ɂ�鎩���X�V�͍s���܂���B
//  ���t�@�C���X�V��ɢMMEffect�����S�čX�V��ŎQ�Ƃ��Ă���G�t�F�N�g�t�@�C�����X�V����K�v������܂��B
//  ��MMM�ł�full_LocalShadow_MMM.fx���[�h�O�ɕύX���Ă��������B�ύX���e�����f����Ȃ��ꍇ��MMM��Cache�t�H���_����S�č폜���čăg���C�B
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// �V���h�E�}�b�v���K�p������͈̓T�C�Y(�t�F�C�X���ʂ�菭���傫�߂̃T�C�Y����͂��܂�)
#define LS_ShadowMapAreaSize  3.5

// �V���h�E�}�b�v���K�p������[�x�T�C�Y(���f���S�̂�菭���傫�߂̃T�C�Y����͂��܂�)
#define LS_ShadowMapDepthLength  20.0

// �e�����̌v�Z�ɗp����f�t�H���g�̃��C�g����(���f�����ł����h�����������ݒ肵�܂�)
#define LS_InitDirection  float3(-0.1, -0.1, 1.0)

// �e�����̌v�Z�ɗp����f�t�H���g�̂ڂ������x(0�`1�Őݒ�,���[�t�Œ����\�Ȃ̂�,�����ł͍ŏ��l��ݒ肵�܂�)
#define LS_InitBlurPower  0.15

// �A�e���Ɩ�����ɘA������f�t�H���g�̊���(0�`1�Őݒ�,���[�t�Œ����\�Ȃ̂�,�����ł͍ŏ��l��ݒ肵�܂�)
#define LS_LightSyncShade  0.5

// �Օ��e���Ɩ�����ɘA������f�t�H���g�̊���(0�`1�Őݒ�,���[�t�Œ����\�Ȃ̂�,�����ł͍ŏ��l��ݒ肵�܂�)
#define LS_LightSyncShadow  0.3

// �Օ��e�̔Z�x���Ɩ�����ɘA������f�t�H���g�̊���(0�`1�Őݒ�,���[�t�Œ����\�Ȃ̂�,�����ł͍ŏ��l��ݒ肵�܂�)
#define LS_LightSyncDensity  0.8

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#define LS_ShadowMapBuffSize  512

// VSM�V���h�E�}�b�v�̎���
#define LS_UseSoftShadow  1
// 0 : �������Ȃ�(�\�t�g�V���h�E�͎g���Ȃ����Ǖ`�摬�x�͌��シ��)
// 1 : ��������(�\�t�g�V���h�E���g����悤�ɂȂ�܂�)

// �t�F�C�X�ގ������ʂ��邽�߂̃L�[���l(�ގ��̃L�[�ݒ肵�����ˋ��x��10�{�����l�̏���������͂��܂�)
#define LS_ExecKey  0.39


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^��`

// �R���g���[���p�����[�^
float3   LocalShadow_BonePos     : CONTROLOBJECT < string name = "(self)"; string item = "LS_Center"; >;
float4x4 LocalShadow_BoneMatrix  : CONTROLOBJECT < string name = "(self)"; string item = "LS_Center"; >;
float    LocalShadow_MorphLtSync : CONTROLOBJECT < string name = "(self)"; string item = "LS_LtSync"; >;

// �N�H�[�^�j�I���̐ώZ
float4 LocalShadow_MulQuat(float4 q1, float4 q2)
{
   return float4(cross(q1.xyz, q2.xyz)+q1.xyz*q2.w+q2.xyz*q1.w, q1.w*q2.w-dot(q1.xyz, q2.xyz));
}

// �N�H�[�^�j�I���̉�]
float3 LocalShadow_RotQuat(float3 v1, float3 v2, float3 pos)
{
   float3 s = cross(v2, v1);
   if( !any(s) ) s = float3(1,0,0);
   float3 v = normalize( s );
   float rot = acos( dot(v1, v2) );
   float sinHD = sin(0.5f * rot);
   float cosHD = cos(0.5f * rot);
   float4 q1 = float4(v*sinHD, cosHD);
   float4 q2 = float4(-v*sinHD, cosHD);
   float4 q = LocalShadow_MulQuat( LocalShadow_MulQuat(q2, float4(pos, 0.0f)), q1);

   return q.xyz;
}

// ���C�g����(�G�t�F�N�g�ݒ����)
float3 LocalShadow_LtDirection : DIRECTION < string Object = "Light"; >;
static float3 LocalShadow_LtCtrlDir = LocalShadow_RotQuat(float3(0,0.0001,1), normalize(LocalShadow_BoneMatrix._31_32_33), normalize(LS_InitDirection));
static float  LocalShadow_MorphLtSync1 = lerp(LS_LightSyncShade, 1.0f, LocalShadow_MorphLtSync);
static float  LocalShadow_MorphLtSync2 = lerp(LS_LightSyncShadow, 1.0f, LocalShadow_MorphLtSync);
static float3 LocalShadow_LightDirection = normalize(lerp(LocalShadow_LtCtrlDir, LocalShadow_LtDirection, LocalShadow_MorphLtSync2));


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ���W�ϊ��s��

// ���C�g�����̃r���[�ϊ��s��
float4x4 LocalShadow_LightViewMatrix()
{
   // z�������x�N�g��
   float3 viewZ = LocalShadow_LightDirection;

   // x�������x�N�g��
   float3 viewX = cross( LocalShadow_BoneMatrix._21_22_23, LocalShadow_LightDirection ); 

   // x�������x�N�g���̐��K��(LookDir��LookUpDir�̕�������v����ꍇ�͓��ْl�ƂȂ�)
   if( !any(viewX) ) viewX = LocalShadow_BoneMatrix._11_21_31;
   viewX = normalize(viewX);

   // y�������x�N�g��
   float3 viewY = cross( viewZ, viewX );  // ���ɐ����Ȃ̂ł���Ő��K��

   // �r���[���W�ϊ��̉�]�s��
   float3x3 ltViewRot = float3x3( viewX.x, viewY.x, viewZ.x,
                                  viewX.y, viewY.y, viewZ.y,
                                  viewX.z, viewY.z, viewZ.z );

   // ���̌����ʒu
   float3 ltViewPos = LocalShadow_BonePos - LocalShadow_LightDirection * LS_ShadowMapDepthLength;

   // �r���[�ϊ��s��
   return float4x4( ltViewRot[0],  0,
                    ltViewRot[1],  0,
                    ltViewRot[2],  0,
                   -mul( ltViewPos, ltViewRot ), 1 );
}


// ���C�g�����̎ˉe�ϊ��s��
float4x4 LocalShadow_LightProjMatrix()
{
   float s = 2.0f / LS_ShadowMapAreaSize;
   float d = 0.5f / LS_ShadowMapDepthLength;

   return float4x4( s, 0, 0, 0,
                    0, s, 0, 0,
                    0, 0, d, 0,
                    0, 0, 0, 1 );
}


float4x4 LocalShadow_WorldMatrix : WORLD;

static float4x4 LocalShadow_LightViewProjMatrix = mul( LocalShadow_LightViewMatrix(), LocalShadow_LightProjMatrix() );
static float4x4 LocalShadow_LightWorldViewProjMatrix = mul( LocalShadow_WorldMatrix, LocalShadow_LightViewProjMatrix );


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef LOCALSHADOWMAPDRAW

// �t�F�C�X�ގ�����
float LocalShadow_SpecularPower : SPECULARPOWER < string Object = "Geometry"; >;
static bool LocalShadow_Valid = (abs(frac(LocalShadow_SpecularPower*10.0f) - LS_ExecKey) < 0.001f);

// ���C�g�����̏C��
float3 LocalShadow_GetLightDirection(float3 ltDir)
{
    if( LocalShadow_Valid ){
        ltDir = normalize( lerp(LocalShadow_LtCtrlDir, ltDir, LocalShadow_MorphLtSync1) );
    }
    return ltDir;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �V���h�E�}�b�v�֘A�̏���

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#define SMAPSIZE_WIDTH   LS_ShadowMapBuffSize
#define SMAPSIZE_HEIGHT  LS_ShadowMapBuffSize

#if LS_UseSoftShadow==1
    #define TEX_FORMAT  "D3DFMT_G32R32F"
    #define TEX_MIPLEVELS  0
#else
    #define TEX_FORMAT  "D3DFMT_R32F"
    #define TEX_MIPLEVELS  1
#endif

// �I�t�X�N���[���V���h�E�}�b�v�o�b�t�@
texture LS_ShadowMap : OFFSCREENRENDERTARGET <
    string Description = "LocalShadow(���f���g�ݍ��ݔ�)�̃V���h�E�}�b�v";
    int Width  = SMAPSIZE_WIDTH;
    int Height = SMAPSIZE_HEIGHT;
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    string Format = TEX_FORMAT;
    bool AntiAlias = false;
    int Miplevels = TEX_MIPLEVELS;
    string DefaultEffect = 
        "self = LocalShadow_ShadowMap.fxsub;"
        "* = hide;";
>;
sampler LocalShadow_ShadowMapSamp = sampler_state {
    texture = <LS_ShadowMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// �e�Z�x
float LocalShadow_MorphSdDens1 : CONTROLOBJECT < string name = "(self)"; string item = "LS_Dens-"; >;
float LocalShadow_MorphSdDens2 : CONTROLOBJECT < string name = "(self)"; string item = "LS_Dens+"; >;
static float LocalShadow_MorphLtSync3 = lerp(LS_LightSyncDensity, 1.0f, LocalShadow_MorphLtSync);
static float LocalShadow_LtCtrlDens = smoothstep(-1.5f+1.5f*LocalShadow_MorphLtSync3, LocalShadow_MorphLtSync3, dot(LocalShadow_LightDirection, LocalShadow_LtDirection));
static float LocalShadow_Density1 = (1.0f - LocalShadow_MorphSdDens1) * LocalShadow_LtCtrlDens;
static float LocalShadow_Density2 = 1.0f + 5.0f * LocalShadow_MorphSdDens2;


#if LS_UseSoftShadow==1
// VSM�V���h�E�}�b�v�֘A�̏���

    // �ڂ������x
    float LocalShadow_MorphSdBulr : CONTROLOBJECT < string name = "(self)"; string item = "LS_Blur"; >;
    static float LocalShadow_ShadowBulrPower = lerp(LS_InitBlurPower, 1.0f, LocalShadow_MorphSdBulr) * 5.0f;

    // �V���h�E�}�b�v�̎��ӃT���v�����O��
    #define BASESMAP_COUNT  4

    // �V���h�E�}�b�v�o�b�t�@�T�C�Y
    #define SMAPSIZE_WIDTH   LS_ShadowMapBuffSize
    #define SMAPSIZE_HEIGHT  LS_ShadowMapBuffSize

    // �V���h�E�}�b�v�̃T���v�����O�Ԋu
    static float2 LocalShadow_SMapSampStep = float2(LocalShadow_ShadowBulrPower/SMAPSIZE_WIDTH, LocalShadow_ShadowBulrPower/SMAPSIZE_HEIGHT);

    // �V���h�E�}�b�v�̎��ӃT���v�����O1
    float2 LocalShadow_GetZPlotSampleBase1(float2 Tex, float smpScale)
    {
        float2 smpStep = LocalShadow_SMapSampStep * smpScale;
        float mipLv = log2( max(SMAPSIZE_WIDTH*smpStep.x, 1.0f) );
        float2 zplot = tex2Dlod(LocalShadow_ShadowMapSamp, float4(Tex, 0, mipLv)).xy * 2.0f;
        zplot += tex2Dlod(LocalShadow_ShadowMapSamp, float4(Tex+smpStep*float2(-1,-1), 0, mipLv)).xy;
        zplot += tex2Dlod(LocalShadow_ShadowMapSamp, float4(Tex+smpStep*float2( 1,-1), 0, mipLv)).xy;
        zplot += tex2Dlod(LocalShadow_ShadowMapSamp, float4(Tex+smpStep*float2(-1, 1), 0, mipLv)).xy;
        zplot += tex2Dlod(LocalShadow_ShadowMapSamp, float4(Tex+smpStep*float2( 1, 1), 0, mipLv)).xy;
        return (zplot / 6.0f);
    }

    // �V���h�E�}�b�v�̎��ӃT���v�����O2
    float2 LocalShadow_GetZPlotSampleBase2(float2 Tex, float smpScale)
    {
        float2 smpStep = LocalShadow_SMapSampStep * smpScale;
        float mipLv = log2( max(SMAPSIZE_WIDTH*smpStep.x, 1.0f) );
        float2 zplot = tex2Dlod(LocalShadow_ShadowMapSamp, float4(Tex, 0, mipLv)).xy * 2.0f;
        zplot += tex2Dlod(LocalShadow_ShadowMapSamp, float4(Tex+smpStep*float2(-1, 0), 0, mipLv)).xy;
        zplot += tex2Dlod(LocalShadow_ShadowMapSamp, float4(Tex+smpStep*float2( 1, 0), 0, mipLv)).xy;
        zplot += tex2Dlod(LocalShadow_ShadowMapSamp, float4(Tex+smpStep*float2( 0,-1), 0, mipLv)).xy;
        zplot += tex2Dlod(LocalShadow_ShadowMapSamp, float4(Tex+smpStep*float2( 0, 1), 0, mipLv)).xy;
        return (zplot / 6.0f);
    }

    // �Z���t�V���h�E�̎Օ��m�������߂�
    float LocalShadow_GetSelfShadowRate(float2 SMapTex, float z)
    {
        // �V���h�E�}�b�v���Z�v���b�g�̓��v����(zplot.x:����, zplot.y:2�敽��)
        float2 zplot = float2(0,0);
        float rate = 1.0f;
        float sumRate = 0.0f;
        [unroll]
        for(int i=0; i<BASESMAP_COUNT; i+=2) {
            rate *= 0.5f; sumRate += rate;
            zplot += LocalShadow_GetZPlotSampleBase1(SMapTex, float(i+1)) * rate;
            rate *= 0.5f; sumRate += rate;
            zplot += LocalShadow_GetZPlotSampleBase2(SMapTex, float(i+2)) * rate;
        }
        zplot /= sumRate;

        // �e������(VSM:Variance Shadow Maps�@)
        float variance = max( zplot.y - zplot.x * zplot.x, 0.05f/LS_ShadowMapDepthLength );
        float comp = variance / (variance + max(z - zplot.x, 0.0f));

        comp = smoothstep(0.1f/max(LocalShadow_ShadowBulrPower, 1.0f), 1.0f, comp);
        return (1.0f-(1.0f-comp)*LocalShadow_Density1);
    }

#else
// �\�t�g�V���h�E���g��Ȃ��ꍇ

    #define LocalShadow_SKII1  (200.0f*LS_ShadowMapDepthLength)

    // �Z���t�V���h�E�̎Օ��m�������߂�
    float LocalShadow_GetSelfShadowRate(float2 SMapTex, float z)
    {
        float comp;
        float dist = max( z - tex2D(LocalShadow_ShadowMapSamp, SMapTex).r, 0.0f );
        comp = 1.0f - saturate( dist * LocalShadow_SKII1 - 7.0f);

        return (1.0f-(1.0f-comp)*LocalShadow_Density1);
    }

#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// �Z�x�ݒ�֘A�̏���

struct  LocalShadow_COLOR {
    float4 Color;        // �I�u�W�F�N�g�F
    float4 ShadowColor;  // �e�F
};

// �e�F�ɔZ�x����������
LocalShadow_COLOR LocalShadow_GetShadowDensity(float4 Color, float4 ShadowColor, bool useToon, float LightNormal)
{
    LocalShadow_COLOR Out;
    Out.Color = Color;

    float e = max(LocalShadow_Density2, 1.0f);
    float a = 1.0f / e;
    float b = 1.0f - smoothstep(3.0f, 6.0f, e);
    float3 color = lerp(ShadowColor.rgb*a, ShadowColor.rgb*b, pow(ShadowColor.rgb, e));
    Out.ShadowColor = float4(saturate(color), ShadowColor.a);

    return Out;
}


#endif
