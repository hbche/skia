/*
 * Copyright 2013 The Android Open Source Project
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

#include "include/effects/SkPictureImageFilter.h"

#include "include/core/SkCanvas.h"
#include "include/core/SkPicture.h"
#include "include/effects/SkImageSource.h"
#include "src/core/SkImageFilter_Base.h"
#include "src/core/SkPicturePriv.h"
#include "src/core/SkReadBuffer.h"
#include "src/core/SkSpecialImage.h"
#include "src/core/SkSpecialSurface.h"
#include "src/core/SkValidationUtils.h"
#include "src/core/SkWriteBuffer.h"

namespace {

class SkPictureImageFilterImpl final : public SkImageFilter_Base {
public:
    SkPictureImageFilterImpl(sk_sp<SkPicture> picture, const SkRect& cropRect)
            : INHERITED(nullptr, 0, nullptr)
            , fPicture(std::move(picture))
            , fCropRect(cropRect) {}

protected:
    /*  Constructs an SkPictureImageFilter object from an SkReadBuffer.
     *  Note: If the SkPictureImageFilter object construction requires bitmap
     *  decoding, the decoder must be set on the SkReadBuffer parameter by calling
     *  SkReadBuffer::setBitmapDecoder() before calling this constructor.
     *  @param SkReadBuffer Serialized picture data.
     */
    void flatten(SkWriteBuffer&) const override;
    sk_sp<SkSpecialImage> onFilterImage(const Context&, SkIPoint* offset) const override;

private:
    friend void SkPictureImageFilter::RegisterFlattenables();
    SK_FLATTENABLE_HOOKS(SkPictureImageFilterImpl)

    sk_sp<SkPicture>    fPicture;
    SkRect              fCropRect;

    using INHERITED = SkImageFilter_Base;
};

} // end namespace

sk_sp<SkImageFilter> SkPictureImageFilter::Make(sk_sp<SkPicture> picture) {
    SkRect cropRect = picture ? picture->cullRect() : SkRect::MakeEmpty();
    return Make(std::move(picture), cropRect);
}

sk_sp<SkImageFilter> SkPictureImageFilter::Make(sk_sp<SkPicture> picture, const SkRect& cropRect) {
    return sk_sp<SkImageFilter>(new SkPictureImageFilterImpl(std::move(picture), cropRect));
}

void SkPictureImageFilter::RegisterFlattenables() {
    SK_REGISTER_FLATTENABLE(SkPictureImageFilterImpl);
    // TODO (michaelludwig) - Remove after grace period for SKPs to stop using old name
    SkFlattenable::Register("SkPictureImageFilter", SkPictureImageFilterImpl::CreateProc);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

sk_sp<SkFlattenable> SkPictureImageFilterImpl::CreateProc(SkReadBuffer& buffer) {
    sk_sp<SkPicture> picture;
    SkRect cropRect;

    if (buffer.readBool()) {
        picture = SkPicturePriv::MakeFromBuffer(buffer);
    }
    buffer.readRect(&cropRect);

    return SkPictureImageFilter::Make(std::move(picture), cropRect);
}

void SkPictureImageFilterImpl::flatten(SkWriteBuffer& buffer) const {
    bool hasPicture = (fPicture != nullptr);
    buffer.writeBool(hasPicture);
    if (hasPicture) {
        SkPicturePriv::Flatten(fPicture, buffer);
    }
    buffer.writeRect(fCropRect);
}

sk_sp<SkSpecialImage> SkPictureImageFilterImpl::onFilterImage(const Context& ctx,
                                                              SkIPoint* offset) const {
    if (!fPicture) {
        return nullptr;
    }

    SkRect floatBounds;
    ctx.ctm().mapRect(&floatBounds, fCropRect);
    SkIRect bounds = floatBounds.roundOut();
    if (!bounds.intersect(ctx.clipBounds())) {
        return nullptr;
    }

    SkASSERT(!bounds.isEmpty());

    // Given the standard usage of the picture image filter (i.e., to render content at a fixed
    // resolution that, most likely, differs from the screen's) disable LCD text.
    SkSurfaceProps props(0, kUnknown_SkPixelGeometry);
    sk_sp<SkSpecialSurface> surf(ctx.makeSurface(bounds.size(), &props));
    if (!surf) {
        return nullptr;
    }

    SkASSERT(kUnknown_SkPixelGeometry == surf->props().pixelGeometry());

    SkCanvas* canvas = surf->getCanvas();
    SkASSERT(canvas);
    canvas->clear(0x0);

    canvas->translate(-SkIntToScalar(bounds.fLeft), -SkIntToScalar(bounds.fTop));
    canvas->concat(ctx.ctm());
    canvas->drawPicture(fPicture);

    offset->fX = bounds.fLeft;
    offset->fY = bounds.fTop;
    return surf->makeImageSnapshot();
}
