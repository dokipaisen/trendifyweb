package com.poly.controller;

import com.poly.entity.Banner;
import com.poly.repository.BannerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/banners")
public class BannerController {

    @Autowired
    private BannerRepository bannerRepository;

    @GetMapping
    public List<Banner> getActiveBanners() {
        return bannerRepository.findByActiveTrueOrderByDisplayOrderAsc();
    }
}
