/*
 * Copyright 2018 Google Inc.
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

#include "src/gpu/mtl/GrMtlGpu.h"
#include "src/gpu/mtl/GrMtlUtil.h"

#if !__has_feature(objc_arc)
#error This file must be compiled with Arc. Use -fobjc-arc flag
#endif

GrMtlStencilAttachment::GrMtlStencilAttachment(GrMtlGpu* gpu,
                                               SkISize dimensions,
                                               const Format& format,
                                               const id<MTLTexture> stencilView)
    : GrStencilAttachment(gpu, dimensions, format.fStencilBits,
                          stencilView.sampleCount, GrProtected::kNo)
    , fFormat(format)
    , fStencilView(stencilView) {
    this->registerWithCache(SkBudgeted::kYes);
}

GrMtlStencilAttachment* GrMtlStencilAttachment::Create(GrMtlGpu* gpu,
                                                       SkISize dimensions,
                                                       int sampleCnt,
                                                       const Format& format) {
    MTLTextureDescriptor* desc =
        [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:format.fInternalFormat
                                                           width:dimensions.width()
                                                          height:dimensions.height()
                                                       mipmapped:NO];
    if (@available(macOS 10.11, iOS 9.0, *)) {
        desc.storageMode = MTLStorageModePrivate;
        desc.usage = MTLTextureUsageRenderTarget;
    }
    desc.sampleCount = sampleCnt;
    if (sampleCnt > 1) {
        desc.textureType = MTLTextureType2DMultisample;
    }
    return new GrMtlStencilAttachment(gpu, dimensions, format,
                                      [gpu->device() newTextureWithDescriptor:desc]);
}

GrMtlStencilAttachment::~GrMtlStencilAttachment() {
    // should have been released or abandoned first
    SkASSERT(!fStencilView);
}

size_t GrMtlStencilAttachment::onGpuMemorySize() const {
    uint64_t size = this->width();
    size *= this->height();
    size *= fFormat.fTotalBits;
    size *= this->numSamples();
    return static_cast<size_t>(size / 8);
}

void GrMtlStencilAttachment::onRelease() {
    fStencilView = nullptr;
    GrStencilAttachment::onRelease();
}

void GrMtlStencilAttachment::onAbandon() {
    fStencilView = nullptr;
    GrStencilAttachment::onAbandon();
}

GrMtlGpu* GrMtlStencilAttachment::getMtlGpu() const {
    SkASSERT(!this->wasDestroyed());
    return static_cast<GrMtlGpu*>(this->getGpu());
}
