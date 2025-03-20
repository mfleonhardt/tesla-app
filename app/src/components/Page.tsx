function Page({ children }: { children: React.ReactNode }) {
    return (
        <div className="page-container container mx-auto my-4 px-4 py-8 bg-white rounded-2xl">
            {children}
        </div>
    )
}

export default Page;