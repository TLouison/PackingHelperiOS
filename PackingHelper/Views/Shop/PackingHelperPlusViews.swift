//
//  PackingHelperPlusViews.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/17/24.
//

import SwiftUI

@ViewBuilder
func plusLogoImage(size: CGFloat) -> some View {
    Image(systemName: suitcaseIcon)
        .resizable()
        .scaledToFit()
        .foregroundStyle(defaultLinearGradient)
        .frame(width: size, height: size)
        .roundedBox(background: .thinMaterial)
        .borderGradient()
}

@ViewBuilder
func plusSubscriptionIcon() -> some View {
    Image(systemName: "plus.diamond.fill")
        .symbolRenderingMode(.palette)
        .foregroundStyle(.white, defaultLinearGradient)
}

@ViewBuilder
func plusSubscriptionName() -> some View {
    HStack {
        Text("Packing Helper")
        plusSubscriptionIcon()
            .padding(.leading, -5)
    }
    .font(.headline)
    .bold()
}

@ViewBuilder
func plusSubscriptionWithText(before: String, after: String = "") -> some View {
    HStack {
        Text(before)
        plusSubscriptionName()
        if after != "" {
            Text(after)
        }
    }
}

@ViewBuilder
func plusSubscriptionHeader(header: String = "Subscribe to") -> some View {
    VStack {
        Text(header)
            .font(.subheadline)
            .fontWeight(.light)
        
        plusSubscriptionName()
    }
}

@ViewBuilder
func plusSubscriptionBenefits() -> some View {
    VStack(spacing: 8) {
        VStack(alignment: .leading) {
            Text("∙Packing for Multiple Users")
            Text("∙AI-Assisted Packing Suggestions")
            Text("∙Collaborate With Friends and Family*")
        }
        .font(.callout)
        
        
        Text("* Coming soon")
            .font(.caption)
            .fontWeight(.heavy)
    }
}
